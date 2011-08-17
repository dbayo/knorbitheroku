class AddTokenToUserTokens < ActiveRecord::Migration
  def self.up
    add_column :user_tokens, :token, :string
    add_column :user_tokens, :secret, :string
  end

  def self.down
    remove_column :user_tokens, :secret
    remove_column :user_tokens, :token
  end
end
