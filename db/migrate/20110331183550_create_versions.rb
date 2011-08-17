class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.string :version
      t.text :content
      t.references :document
      t.references :user

      t.timestamps
    end
      add_index :versions, :version, :unique => true
  end

  def self.down
    drop_table :versions
  end
end
