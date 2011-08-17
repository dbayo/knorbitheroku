class CreateFollowers < ActiveRecord::Migration
  def self.up
    create_table :followers do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.string :group

      t.timestamps
    end
    add_index :followers, :follower_id
    add_index :followers, :followed_id
    add_index :followers, [:follower_id, :followed_id], :unique => true
  end

  def self.down
    drop_table :followers
  end
end
