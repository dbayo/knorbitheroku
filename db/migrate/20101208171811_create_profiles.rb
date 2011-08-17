class CreateProfiles < ActiveRecord::Migration
  	def self.up
	    create_table :profiles do |t|
			    t.text :keyword1     
		  	  t.text :keyword2 
		  	  t.text :keyword3
		  	  t.text :keyword4
	  	    t.text :keyword5
		  	  t.text :qualifier1     
		  	  t.text :qualifier2 
		  	  t.text :qualifier3
		  	  t.text :qualifier4
		  	  t.text :qualifier5
		  	  t.text :oftentags
	
	      	t.integer :user_id
	
	      	t.timestamps
	    end
	    add_index :profiles, :user_id
  	end

  	def self.down
    	drop_table :profiles
  	end
end
