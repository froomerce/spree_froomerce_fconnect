#class Spree::Product
Product.class_eval do 
  has_one :froomerce_product_status, :dependent => :destroy
end