class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :organization
      t.string :phone
      t.string :post_address
      t.text :language
      t.text :geospace
      t.integer :credit
      t.integer :reputation
      t.string :account
      t.string :userlevel
      t.string :active
      t.integer :maxinv
      t.string :allowsms
      t.string :allowalerts
      
      t.integer :user_id

      t.timestamps
    end
    add_index :accounts, :user_id
  end

  def self.down
    drop_table :accounts
  end
end
