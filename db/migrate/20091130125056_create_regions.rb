class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.string :name
      t.integer :parent_region_id
      t.integer :status
      t.float :latitude
      t.float :longitude
      t.integer :rank

      t.timestamps
    end
  end

  def self.down
    drop_table :regions
  end
end
