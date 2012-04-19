require 'api_calls'
class Admin::FroomercesController < Admin::BaseController
  
  include Api_calls
  before_filter :authenticate_user!
  

  def index
    if FroomerceUser.exists?
      redirect_to :action => "export_shop"
    end
  end
  
  def export_shop
    unless FroomerceUser.exists?
      flash[:error] = I18n.t('.error.no_session')
      redirect_to :action => "index"; return
    end
    @user = FroomerceUser.first
    @regions = ""
    config = FroomerceConfig.first
    if !config.nil? && config.status != 'Inprogress'
      @froomerce_config = config
    else
      @froomerce_config = ""
      call = "action_type=get_regions"
      result = make_api_call(call, FroomerceConfig::VERIFICATION[:user_url], 0, @user.email)
      if result != -1
        if result['status'] == 'success'
          @regions = result
        else
          flash[:error] = I18n.t(".error.e#{result['error']['code']}")
        end
      else
        flash[:error] = I18n.t('.error.HTTPfaliure')
      end
    end
  end
  
  def create_shop
    unless FroomerceConfig.first.nil?
      redirect_to(:action => "export_products")
      return
    end
    user = FroomerceUser.first
    froomerce_config = FroomerceConfig.new(params[:froomerce_config])
    unless froomerce_config.region_id == 0 || froomerce_config.shop_id == 0
      if Spree::Config[:site_name].blank?
        call = {'secret_token' => FroomerceConfig::VERIFICATION[:token],'user_id'=> user.froomerce_user_id, 'region_id' => froomerce_config.region_id, 'shop_name' => 'Spree Store', 'action_type' => 'create_shop' }
      else
        call = {'secret_token' => FroomerceConfig::VERIFICATION[:token],'user_id'=> user.froomerce_user_id, 'region_id' => froomerce_config.region_id, 'shop_name' => Spree::Config[:site_name], 'action_type' => 'create_shop' }
      end
      result = make_api_call(call, FroomerceConfig::VERIFICATION[:shop_url], 2, user.email)
      if result != -1
        if result['status'] == 'success'
          froomerce_config.froomerce_shop_id = result['data']['shop_id']
          froomerce_config.shop_id = 1 
           if froomerce_config.save
              redirect_to(:action => "export_products")
              return
           end
        else
          flash[:error] = I18n.t('.error.shop_error')
          redirect_to :action => "export_shop"
        return
        end
      else
        flash[:error] = I18n.t('.error.HTTPfaliure')
        redirect_to :action => "export_shop"
        return
      end
    else
      flash[:error] = I18n.t('.error.invalid_selection')
      redirect_to :action => "export_shop"
    end
  end
  
  def export_products
    user = FroomerceUser.first
    config = FroomerceConfig.first
    call = {'secret_token' => FroomerceConfig::VERIFICATION[:token],'user_id'=> user.froomerce_user_id, 'shop_id' => config.froomerce_shop_id, 'temp_url' => root_url + "froomerce_products?per_page=#{FroomerceConfig::FEED_CONFIG[:temp_limit]}" , 'feed_url' => root_url + "froomerce_feed?page=1&per_page=#{FroomerceConfig::FEED_CONFIG[:feed_per_page]}" ,'request_url' =>  root_url + 'froomerce_call_backs', 'network_id' => FroomerceConfig::FEED_CONFIG[:network_id] , 'action_type' => 'import_feed' }
    result = make_api_call(call, FroomerceConfig::VERIFICATION[:feed_url], 2, user.email)
    if result != -1
        if result['status'] == 'success'
          config.reload # reload config again!
          config.update_attribute(:status , 'Exporting Products') unless config.status.eql? 'Exported'
          flash[:notice] = I18n.t('shop_success')
          redirect_to(:action => "export_shop")
        else
          flash[:error] = I18n.t('.error.shop_error')
          redirect_to :action => "export_shop"
        return
        end
    else
      flash[:error] = I18n.t('.error.HTTPfaliure')
      redirect_to :action => "export_shop"
      return
    end
  end
  
  def export_facebook
    @config = FroomerceConfig.first
    @user = FroomerceUser.first
    @token = FroomerceConfig::VERIFICATION[:token]
    if is_dummy?(@user.email)
      @action = FroomerceConfig::VERIFICATION[:temp_base]+FroomerceConfig::VERIFICATION[:facebook_url]
    else
      @action = FroomerceConfig::VERIFICATION[:base]+FroomerceConfig::VERIFICATION[:facebook_url]
    end
    if !@config.blank? && @config.status != 'Inprogress'
      @flag = false
      call = {'secret_token' => FroomerceConfig::VERIFICATION[:token], 'shop_ids' => @config.froomerce_shop_id, 'action_type' => 'verify_shop_export'}
      result = make_api_call(call, FroomerceConfig::VERIFICATION[:facebook_url], 2, @user.email)
      if result != -1
        if result['status'] == 'success'
          @facebook_status = result['data']["#{@config.froomerce_shop_id}"]
          if @facebook_status == 'exported'
            @flag = true
          else
            @flag = false
          end
        else
          flash[:error] = I18n.t(".error.e#{result['error']['code']}")
        end
      else
        flash[:error] = I18n.t('.error.HTTPfaliure')
      end
    end
  end
  
  def export_facebook_widgets
    config = FroomerceConfig.first
    if !config.nil? && config.status != 'Inprogress'
      params[:search] ||= {}
      params[:search][:deleted_at_is_null] = true
      params[:search][:count_on_hand_does_not_equal] ||= 0
      params[:search][:froomerce_product_status_status_is_true] = true
      @search = Product.search(params[:search])
      @products = @search.relation.page(params[:page]).per(Spree::Config[:admin_products_per_page])
    else
      redirect_to :action => "export_shop"
    end
  end
  
  def make_widget
    user = FroomerceUser.first
    config = FroomerceConfig.first
    if params[:product_ids].blank?
      flash[:notice] = I18n.t('.error.invalid_widget_selection')
      redirect_to(:action => "export_facebook_widgets")
      return
    end
    product_ids = params[:product_ids].join(',')
    call = {'secret_token' => FroomerceConfig::VERIFICATION[:token], 'user_id' => user.froomerce_user_id , 'shop_id' => config.froomerce_shop_id, 'product_ids' => product_ids ,'action_type' => 'export_widget'}
    result = make_api_call(call, FroomerceConfig::VERIFICATION[:facebook_url], 2, user.email)
    if result != -1
      if result['status'] == 'success'
        widget_id = result['data']['widget_id']
        if is_dummy?(user.email)
          flash[:notice] = (I18n.t('widget_saved') + "<a href=\"#{FroomerceConfig::VERIFICATION[:temp_base] + FroomerceConfig::VERIFICATION[:widget_url]}?widget_id=#{widget_id}&secret_token=#{FroomerceConfig::VERIFICATION[:token]}&user_id=#{user.froomerce_user_id}\" target=\"_blank\"> here </a>" + I18n.t('widget_continue')).html_safe
        else
          flash[:notice] = (I18n.t('widget_saved') + "<a href=\"#{FroomerceConfig::VERIFICATION[:base] + FroomerceConfig::VERIFICATION[:widget_url]}?widget_id=#{widget_id}&secret_token=#{FroomerceConfig::VERIFICATION[:token]}&user_id=#{user.froomerce_user_id}\" target=\"_blank\"> here </a>" + I18n.t('widget_continue')).html_safe
        end
      else
        flash[:error] = I18n.t(".error.e#{result['error']['code']}")
      end
    else
      flash[:error] = I18n.t('.error.HTTPfaliure')
    end
    redirect_to(:action => "export_facebook_widgets")
  end
  
  def create
    @froomerce_user = FroomerceUser.new(params[:froomerce_user])
    if !@froomerce_user.email.match(/[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/) or @froomerce_user.password == ""
      flash[:error] = I18n.t('.error.validation_error')
      redirect_to :action => "index"
      return
    end
    call = "email=#{@froomerce_user.email}&password=#{@froomerce_user.password}&action_type=verify_login"
    result = make_api_call(call, FroomerceConfig::VERIFICATION[:user_url], 1, @froomerce_user.email)
    if result != -1
      if result['status'] == 'success'
        @froomerce_user.froomerce_user_id = result['data']['user_id']
        unless FroomerceUser.exists?
          @froomerce_user.save
        end
        flash[:notice] = "Successfully Logged In!"
        redirect_to :action => "export_shop"
        return
      else
        flash[:error] = I18n.t(".error.e#{result['error']['code']}")
        redirect_to :action => "index"
      end
    else
      flash[:error] = I18n.t('.error.HTTPfaliure')
      redirect_to :action => "index"
    end
  end
end