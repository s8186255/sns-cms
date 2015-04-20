class CreateDisplayTopics < ActiveRecord::Migration
  def self.up
    create_table :display_topics do |t|
      t.integer :topic_id
      t.integer :referee_id
      t.integer :verifier_id
      t.integer :status
      t.integer :type
      t.string :region
      t.date :from
      t.date :to

      t.timestamps
    end
  end

  def self.down
    drop_table :display_topics
  end
end
