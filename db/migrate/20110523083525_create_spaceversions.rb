class CreateSpaceversions < ActiveRecord::Migration
  def self.up
    create_table :spaceversions do |t|
      t.string :name
      t.text :content
      t.references :space
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :spaceversions
  end
end
