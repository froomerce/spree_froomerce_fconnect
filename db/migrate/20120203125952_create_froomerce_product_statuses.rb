class CreateFroomerceProductStatuses < ActiveRecord::Migration
  def change
    create_table :froomerce_product_statuses, :id => false  do |t|
      t.integer :product_id,        :null => false
      t.column  :status,            :boolean,         :default => true,      :null => false
      t.timestamps
    end
    execute "ALTER TABLE froomerce_product_statuses ADD PRIMARY KEY (product_id);"
  end
end
