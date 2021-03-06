class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :item_type_id
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
