class CreateCloudTools < ActiveRecord::Migration
  def self.up
    create_table :cloud_tools do |t|
      t.text :name
      t.integer :info_type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :cloud_tools
  end
end
