class CreateTopicTypes < ActiveRecord::Migration
  def self.up
    create_table :topic_types do |t|
      t.string :name
      t.integer :parent_topic_type_id
      t.integer :status
      t.integer :status
      t.integer :creator_id
      t.integer :verifier_id

      t.timestamps
    end
  end

  def self.down
    drop_table :topic_types
  end
end
