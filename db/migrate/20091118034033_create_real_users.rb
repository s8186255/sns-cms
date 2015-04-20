class CreateRealUsers < ActiveRecord::Migration
  def self.up
    create_table :real_users do |t|
      t.string :name
      t.integer :id_card_number
      t.string :phone_number

      t.timestamps
    end
  end

  def self.down
    drop_table :real_users
  end
end
