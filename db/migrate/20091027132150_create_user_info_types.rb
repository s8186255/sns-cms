class CreateUserInfoTypes < ActiveRecord::Migration
  def self.up
    create_table :user_info_types do |t|
      t.integer :user_id,:info_type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_info_types
  end
end
