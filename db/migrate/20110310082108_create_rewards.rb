class CreateRewards < ActiveRecord::Migration
  def self.up
    create_table :rewards do |t|
      t.integer :owner_id
      t.integer :contributor_id
      t.integer :job_id
      t.integer :points
      t.integer :total

      t.timestamps
    end
  end

  def self.down
    drop_table :rewards
  end
end
