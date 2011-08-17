class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :user_id
      t.integer :job_id
      t.integer :code
      t.string :message

      t.timestamps
    end
 
    add_index :activities, :user_id
    add_index :activities, :job_id
  end

  def self.down
    drop_table :activities
  end
end
