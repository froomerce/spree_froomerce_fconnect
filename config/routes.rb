Rails.application.routes.draw do

  namespace :admin do
    resources :froomerces do
      get :export_facebook
      get :export_shop
      post :create_shop
      get :export_products
      get :export_facebook_widgets
      post :make_widget
    end
   match 'froomerce' => 'froomerces#index',  :as => :froomerce
   match 'froomerce/export_to_facebook' => 'froomerces#export_facebook',  :as => :export_facebook
   match 'froomerce/export_to_froomerce' => 'froomerces#export_shop',  :as => :export_shop
   match 'froomerce/creating_shop' => 'froomerces#create_shop'
   match 'froomerce/exporting_products' => 'froomerces#export_products'
   match 'froomerce/export_widgets_to_facebook' => 'froomerces#export_facebook_widgets'
   match 'froomerce/make_widget' => 'froomerces#make_widget'
  end

  resources :froomerce_products do
    get :feed_url
    get :call_backs
    get :post_widget
  end
  match 'froomerce_feed' => 'froomerce_products#feed_url',  :as => :feed_url
  match 'froomerce_call_backs' => 'froomerce_products#call_backs'
  match 'truncate_froomerce_configuration' => 'froomerce_products#truncate_all_tables'
end
