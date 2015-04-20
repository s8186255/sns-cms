class CreateHahas < ActiveRecord::Migration
  def self.up
    create_table :hahas do |t|
      t.string :book

      t.timestamps
    end
  end

  def self.down
    drop_table :hahas
  end
end
