class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :from_id
      t.integer :to_id
      t.string :subject
      t.text :body
      t.boolean :read

      t.timestamps
    end
    
    add_index :messages, :from_id
    add_index :messages, :to_id 
  end

  def self.down
    drop_table :messages
  end
end
