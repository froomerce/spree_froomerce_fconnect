class FroomerceConfig < ActiveRecord::Base
  
  VERIFICATION = {:base => 'http://froomerce.com/', :temp_base => 'http://servis.pk/', :token => '5e5225e8d60e8ec72a7fd96135a0e865', :user_url => 'api/user/index', :shop_url => 'api/shop/index',:feed_url => 'api/productfeed/index', :facebook_url => 'api/faceshop/index',:widget_url => 'api/faceshop/export', :feed_status_url => 'api/productfeed/index'}
  FEED_CONFIG = {:temp_limit => 200, :feed_per_page => 200, :network_id => 5}
  
  validates_inclusion_of :status, :in => %w(Inprogress Exporting Exported)
  
end
