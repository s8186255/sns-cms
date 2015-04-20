class CreateInfoCounters < ActiveRecord::Migration
  def self.up
    create_table :info_counters do |t|
      t.integer :inf_id
      t.integer :comment_count
      t.integer :view_count

      t.timestamps
    end
  end

  def self.down
    drop_table :info_counters
  end
end
