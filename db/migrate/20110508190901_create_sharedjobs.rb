class CreateSharedjobs < ActiveRecord::Migration
  def self.up
    create_table :sharedjobs do |t|
        t.integer :from_id
        t.string :to_email
        t.integer :job_id
        t.string :method

        t.timestamps
    end
    add_index :sharedjobs, :job_id
  end

  def self.down
    drop_table :sharedjobs
  end
end
