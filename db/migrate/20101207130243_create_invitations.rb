class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :from_id
      t.string :to_email
      t.integer :job_id
      t.string :status

      t.timestamps
    end    
  end

  def self.down
    drop_table :invitations
  end
end
