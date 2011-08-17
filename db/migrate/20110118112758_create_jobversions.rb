class CreateJobversions < ActiveRecord::Migration
  def self.up
    create_table :jobversions do |t|
      t.integer :job_id
      t.integer :user_id
      t.string :version_name
      t.string :version_wiki

      t.timestamps
    end
  end

  def self.down
    drop_table :jobversions
  end
end
