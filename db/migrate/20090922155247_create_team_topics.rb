class CreateTeamTopics < ActiveRecord::Migration
  def self.up
    create_table :team_topics do |t|
      t.integer :team_id
      t.integer :topic_id
      t.integer :if_maintain_topic
      t.integer :if_follow_topic

      t.timestamps
    end
  end

  def self.down
    drop_table :team_topics
  end
end
