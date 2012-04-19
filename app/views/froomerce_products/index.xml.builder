xml.instruct! :xml, :version=>"1.0"

xml.data do
  xml.products do
    @products.each do |product|
      unless product.count_on_hand < 1
        xml.product do
          xml.product_id{xml.cdata!("#{product.id}")}
          if product.has_variants?
            xml.is_configurable{xml.cdata!("#{1}")}
          else
            xml.is_configurable{xml.cdata!("#{0}")}
          end
          xml.title{xml.cdata!(product.name)}
          price = product.price
          xml.price{xml.cdata!("#{price}")}
          xml.shipping_info
          xml.currency_symbol{xml.cdata!((number_to_currency price).gsub(/[^$]/, ""))}
          xml.product_link{xml.cdata!(root_url+"products/"+product.permalink)}
          i = 1
          if @taxon
            categories = ""
            product.taxons.each do |tax|
              if cate = tax.is_category("")
                categories = cate+","+categories
              end
            end
            xml.category_id{xml.cdata!(categories.chop)}
          else
            xml.category_id
          end
          product.images.each do |image|
            if i
              xml.image_small{xml.cdata!(root_url.chop+image.attachment.url(:small))}
              xml.image_large{xml.cdata!(root_url.chop+image.attachment.url(:large))}
              i = nil
            else
              xml.img{xml.cdata!(root_url.chop+image.attachment.url(:large))}
            end
          end
          if product.description
            xml.product_detail{xml.cdata!(product.description)}
          else
            xml.product_detail
          end
          if product.properties
            xml.attributes do
              i = 0
              product.properties.each do |property|
                xml.attribute do
                  xml.label{xml.cdata!(property.presentation)}
                  xml.value{xml.cdata!(product.product_properties[i].value)}
                end
                i += 1
              end
            end
          end
        end
      end
    end
  end
  if @taxon
    xml.categories do
      @taxon.each do |tax|
        if tax.parent_id.blank?
          if tax.has_children?
            xml.category do
              xml.parent_id{xml.cdata!("0")}
              xml.category_id{xml.cdata!("#{tax.id}")}
              xml.category_name{xml.cdata!(tax.name)}
              xml.position{xml.cdata!("#{tax.lft}")}
            end
          end
        else
          xml.category do
            xml.parent_id{xml.cdata!("#{tax.parent_id}")}
            xml.category_id{xml.cdata!("#{tax.id}")}
            xml.category_name{xml.cdata!(tax.name)}
            xml.position{xml.cdata!("#{tax.lft}")}
          end
        end
      end
    end
  end
end
