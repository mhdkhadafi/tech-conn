class AddLastnameToAccessTokens < ActiveRecord::Migration
  def change
    add_column :access_tokens, :lastname, :string
  end
end
