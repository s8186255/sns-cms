class CreateUserGeoPositions < ActiveRecord::Migration
  def self.up
    create_table :user_geo_positions do |t|
      t.integer :user_id
      t.float :latitude,:longitude
      t.timestamps
    end
  end

  def self.down
    drop_table :user_geo_positions
  end
end
