class CreateContributions < ActiveRecord::Migration
  def self.up
    create_table :contributions do |t|
      t.integer :user_id
      t.integer :job_id

      t.timestamps
    end
    add_index :contributions, [:user_id, :job_id], :unique => true
  end

  def self.down
    drop_table :contributions
  end
end
