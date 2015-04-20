class CreateInfoTypes < ActiveRecord::Migration
  def self.up
    create_table :info_types do |t|
      t.string :title
      t.text :description
 
      t.timestamps
    end
  end

  def self.down
    drop_table :info_types
  end
end
