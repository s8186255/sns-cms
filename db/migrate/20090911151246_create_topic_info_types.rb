class CreateTopicInfoTypes < ActiveRecord::Migration
  def self.up
    create_table :topic_info_types do |t|
      t.integer :topic_id
      t.integer :info_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :topic_info_types
  end
end
