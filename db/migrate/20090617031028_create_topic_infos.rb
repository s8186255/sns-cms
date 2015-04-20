class CreateTopicInfos < ActiveRecord::Migration
  def self.up
    create_table :topic_infos do |t|
      t.integer :topic_id
      t.integer :info_id

      t.timestamps
    end
  end

  def self.down
    drop_table :topic_infos
  end
end
