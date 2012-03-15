class CreateFroomerceConfigs < ActiveRecord::Migration
  def change
    create_table :froomerce_configs do |t|
      t.integer :region_id,           :null => false,   :default => 0
      t.integer :shop_id,             :null => false,   :default => 0
      t.integer :froomerce_shop_id,   :null => false,   :default => 0
      t.column  :status, "ENUM('Inprogress','Exporting Products', 'Exported')", :default => 'Inprogress'

      t.timestamps
    end
  end
end
