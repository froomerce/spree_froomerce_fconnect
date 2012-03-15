class FroomerceProductStatus < ActiveRecord::Base
  
  set_primary_key :product_id
  belongs_to :product
  
  def init_product_id(product_id)
    self.product_id = product_id
  end

  
end
