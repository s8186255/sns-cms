class CreateMaintainings < ActiveRecord::Migration
  def self.up
    create_table :maintainings do |t|
      t.integer :maintainer_id
      t.integer :topic_id
      t.integer :verified
      t.integer :creator_id

      t.timestamps
    end
  end

  def self.down
    drop_table :maintainings
  end
end
