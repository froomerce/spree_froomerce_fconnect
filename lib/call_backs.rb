class CallBacks
  
  def get_attributes(params, root_url)
    id = params[:product_id]
    begin
      product = Product.find(id)
    rescue
      return nil
    end
    options = product.product_option_types
    hash = Hash.new
    return nil unless options.count > 1
    types = []
    types = options.collect {|opt| opt.option_type }
    variants = Variant.find_all_by_product_id(id)
    prod_images = product.images.collect {|img| root_url.chop + img.attachment.url}
    product_images = prod_images.join('^')
    i = 0; j=0
    variants.each do |variant|
      unless variant.is_master
        values = variant.option_values.order('option_type_id ASC')
        images = variant.images.collect {|img| root_url.chop + img.attachment.url}
        additional_images = images.join('^')
        if additional_images.blank?
          additionl_images_url = product_images
        else
          additionl_images_url = product_images + '^' + additional_images
        end
        if additional_images.blank?
          hash[i] = {'product_id' => variant.id, 'price' => variant.price}
        else
          hash[i] = {'product_id' => variant.id, 'price' => variant.price, 'additional_imgs' => additionl_images_url, 'cart_img' => root_url.chop +  variant.images.first.attachment.url}
        end
        types.each do |type|
          hash[i][type.presentation] = values[j].presentation
          j = j.succ
        end
        i = i.succ
        j = 0
      end
      additional_images = ''
      additionl_images_url = ''
    end
    return hash
  end
  
  def export_completed
    config = FroomerceConfig.first
    config.update_attribute(:status, 'Exported')
    return {'status' => 'success'}
  end
  
  def exported_products(params)
    FroomerceProductStatus.update_all(:status => false) if params[:first] && FroomerceProductStatus
    if params[:product_ids]
      products_ids = params[:product_ids].split(',')
      products_ids.each do |id|
        begin
          status = FroomerceProductStatus.find(id)
          status.update_attribute(:status, true)
        rescue
          status = FroomerceProductStatus.new(:status => true)
          status.init_product_id(id.to_i)
          status.save!
        end
      end
    end
    FroomerceProductStatus.delete_all(:status => false) if params[:last] && FroomerceProductStatus
    return {'status' => 'success'}
  end
  
  def verify_cart(params)
    if params[:product_ids]
      product_ids = params[:product_ids].split(',')
      if params[:associated_ids]
        variant_ids = params[:associated_ids].split(',')
        if params[:quantities]
          quantities = params[:quantities].split(',')
          hash = {'status' => 'error', 'error' => {}}
          flag = false
          i = 0; j = 0
          product_ids.each do |product_id|
            if variant_ids[i].eql? '0'
              begin
                product = Product.find(product_id)
              rescue
                return nil
              end
              if product.count_on_hand < quantities[i].to_i
                hash['error'][j] = {'name' => product.name, 'out_of_stock' => product_id, 'available_qty' => product.count_on_hand }
                flag = true unless flag
              end
            else
              begin
                variant = Variant.find(variant_ids[i])
              rescue
                return nil
              end
              if variant.count_on_hand < quantities[i].to_i
                hash['error'][j] = {'name' => variant.product.name, 'out_of_stock' => variant.id, 'available_qty' => variant.count_on_hand }
                flag = true unless flag
              end
            end
            i = i.succ; j = j.succ
          end
          if flag
            return hash
          else
            return {'status' => 'success'}
          end
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  end
  
  def add_to_cart(params)
    if params[:product_ids]
      product_ids = params[:product_ids].split(',')
      if params[:associated_ids]
        variant_ids = params[:associated_ids].split(',')
        if params[:quantities]
          quantities = params[:quantities].split(',')
          i = 0
          product_ids.each do |product|
            variant_ids[i] = Variant.find_by_product_id(product).id.to_s if variant_ids[i].eql? '0'
            i = i.succ
          end
          products =  Hash[*product_ids.zip(variant_ids).flatten]
          quantity =  Hash[*variant_ids.zip(quantities).flatten]
          return products, quantity
        end
      end
    end
  end
end