class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :name
      t.text :content
      t.string :status
      t.references :space

      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
