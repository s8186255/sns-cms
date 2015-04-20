class CreateAvatars < ActiveRecord::Migration
  def self.up
    create_table :avatars do |t|
      t.string :filename
      t.string :content_type
      t.integer :size
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.integer :thumbnail
      t.timestamps
    end
  end

  def self.down
    drop_table :avatars
  end
end
