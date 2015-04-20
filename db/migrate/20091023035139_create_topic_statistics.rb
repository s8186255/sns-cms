class CreateTopicStatistics < ActiveRecord::Migration
  def self.up
    create_table :topic_statistics do |t|
      t.integer :topic_id
      t.integer :infos_quantity
      t.integer :my_infos_quantity
      t.integer :other_infos_quantity
      t.integer :follow_me_user_quantity
      t.integer :maintain_me_user_quantity
      t.integer :comment_quantity
      t.integer :visit_quantity
      t.integer :click_info_quantity
      t.timestamps
    end
  end

  def self.down
    drop_table :topic_statistics
  end
end
