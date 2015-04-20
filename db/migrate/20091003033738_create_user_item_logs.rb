class CreateUserItemLogs < ActiveRecord::Migration
  def self.up
    create_table :user_item_logs do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :payment_status
      t.string :password
      t.integer :counter

      t.timestamps
    end
  end

  def self.down
    drop_table :user_item_logs
  end
end
