require 'api_calls'
class FroomerceProductsController < ApplicationController
  
  include Api_calls
  def index
    searcher = Spree::Config.searcher_class.new(params)
    @products = searcher.retrieve_products
    @taxon = nil
    if Taxonomy.exists?
      @taxon = Taxon.find(:all)
    end
    if @products.count < FroomerceConfig::FEED_CONFIG[:temp_limit]
      config = FroomerceConfig.first
      user = FroomerceUser.first
      call = {'secret_token' => FroomerceConfig::VERIFICATION[:token],'user_id'=> user.froomerce_user_id, 'shop_id' => config.froomerce_shop_id, 'action_type' => 'update_feed_status' }
      result = make_api_call(call, FroomerceConfig::VERIFICATION[:feed_url], 2, user.email)
      if result != -1
        if result['status'] == 'success'
          config.update_attribute(:status, 'Exported')
        end
      end
    end
    render :template => 'froomerce_products/index.xml.builder', :layout => false
  end
  
  def feed_url
    @page_no = params[:page].to_i
    searcher = Spree::Config.searcher_class.new(params)
    @products = searcher.retrieve_products
    if  @products.count < FroomerceConfig::FEED_CONFIG[:feed_per_page]
      @page_no = nil
    end
    @taxon = nil
    if Taxonomy.exists?
      @taxon = Taxon.find(:all)
    end
    render :template => 'froomerce_products/feed_url.xml.builder', :layout => false
  end
  
  def call_backs
    action = params[:action_type]
    unless action.nil?
      callback = CallBacks.new
      if action.eql? 'export_flag'
        @result = callback.export_completed
      elsif action.eql? 'get_attributes'
        @result = callback.get_attributes(params, root_url)
      elsif action.eql? 'verify_cart'
        @result = callback.verify_cart(params)
      elsif action.eql? 'exported_products'
        @result = callback.exported_products(params)
      else
        @products, @quantity = callback.add_to_cart(params)
      end
    end
    @result ||= {}
    respond_to do |format|
      format.json {render :json => @result}
      format.html
    end
  end
  
  def truncate_all_tables
    FroomerceUser.delete_all
    FroomerceConfig.delete_all
    FroomerceProductStatus.delete_all
    flash[:notice] = I18n.t('notify_truncate')
    redirect_to admin_froomerce_path
  end
  
end
