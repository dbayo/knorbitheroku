class CreateSubmittedinvitations < ActiveRecord::Migration
  def self.up
    create_table :submittedinvitations do |t|
      t.integer :from_id
      t.string :to_email
      t.integer :job_id
      t.string :status
      t.string :method
      
      t.timestamps
    end
  end

  def self.down
    drop_table :submittedinvitations
  end
end
