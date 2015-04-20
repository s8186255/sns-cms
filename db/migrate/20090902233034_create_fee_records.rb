class CreateFeeRecords < ActiveRecord::Migration
  def self.up
    create_table :fee_records do |t|
      t.integer :user_id
      t.integer :fee
      t.string :month

      t.timestamps
    end
  end

  def self.down
    drop_table :fee_records
  end
end
