class CreateRecommendedTopics < ActiveRecord::Migration
  def self.up
    create_table :recommended_topics do |t|
      t.integer :topic_id
      t.integer :referer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :recommended_topics
  end
end
