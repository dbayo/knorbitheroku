class CreateSpaces < ActiveRecord::Migration
  def self.up
    create_table :spaces do |t|
      t.string :wiki_name
      t.string :name
      t.string :status
      t.text :content

      t.timestamps
    end
    add_index :spaces, :name
  end

  def self.down
    drop_table :spaces
  end
end
