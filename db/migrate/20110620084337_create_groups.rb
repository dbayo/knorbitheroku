class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.references :user
    
      t.timestamps
    end
    add_index :groups, [:name, :user_id], :unique => true
  end

  def self.down
    drop_table :groups
  end
end
