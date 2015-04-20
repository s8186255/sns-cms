class CreateAvatarFiles < ActiveRecord::Migration
  def self.up
    create_table :avatar_files do |t|
      t.binary :data
    end
  end

  def self.down
    drop_table :avatar_files
  end
end
