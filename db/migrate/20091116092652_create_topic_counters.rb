class CreateTopicCounters < ActiveRecord::Migration
  def self.up
    create_table :topic_counters do |t|
      t.integer :topic_id
      t.integer :following_count
      t.integer :view_count
      t.integer :info_count

      t.timestamps
    end
  end

  def self.down
    drop_table :topic_counters
  end
end
