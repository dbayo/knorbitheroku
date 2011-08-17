class AddDeliciousToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :delicious, :string
  end

  def self.down
    remove_column :accounts, :delicious
  end
end
