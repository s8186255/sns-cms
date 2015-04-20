class CreateUserInfotypes < ActiveRecord::Migration
  def self.up
    create_table :user_infotypes do |t|
      t.integer :user_id
      t.integer :info_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_infotypes
  end
end
