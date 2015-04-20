class CreateFunctions < ActiveRecord::Migration
  def self.up
    create_table :functions do |t|
      t.string :name
      t.text :description
      t.string :controller
      t.string :action
      t.integer :info_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :functions
  end
end
