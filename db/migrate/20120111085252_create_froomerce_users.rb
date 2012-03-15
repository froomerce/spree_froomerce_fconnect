class CreateFroomerceUsers < ActiveRecord::Migration
  def change
    create_table :froomerce_users do |t|
      t.string :email,                :null => false
      t.string :password,             :null => false
      t.integer :froomerce_user_id,   :null => false

      t.timestamps
    end
  end
end
