class CreateUserFunctions < ActiveRecord::Migration
  def self.up
    create_table :user_functions do |t|
      t.integer :user_id
      t.integer :function_id
      t.boolean :status
      t.datetime :up_to

      t.timestamps
    end
  end

  def self.down
    drop_table :user_functions
  end
end
