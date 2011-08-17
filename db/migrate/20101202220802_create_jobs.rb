class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :name
      t.text :description
      t.string :wiki
      t.string :wikispace
      t.text :language
      t.string :public
      t.string :viral
      t.string :smart
      t.string :favorite
      t.string :recomendations

      t.date :date
      t.integer :duration
      t.integer :maxcontributors
      t.text :countriesexcluded

      t.text :template
      t.string :status
     
      t.string :keyword1     
      t.string :keyword2 
      t.string :keyword3
      t.string :keyword4
      t.string :keyword5
      
      t.text :qualifier1     
      t.text :qualifier2 
      t.text :qualifier3
      t.text :qualifier4
      t.text :qualifier5
      
      t.string :checkmarkskills
      t.string :checkmarksections
      
      t.integer :user_id
      t.timestamps
    end
    add_index :jobs, :user_id
    add_index :jobs, [:name, :user_id], :unique => true
  end

  def self.down
    drop_table :jobs
  end
end
