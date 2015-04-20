class CreateInfos < ActiveRecord::Migration
  def self.up
    create_table :infos do |t|
      t.integer :user_id
      t.integer :topic_id
      t.integer :info_type_id
      t.string :title
      t.boolean :if_verified
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :infos
  end
end
