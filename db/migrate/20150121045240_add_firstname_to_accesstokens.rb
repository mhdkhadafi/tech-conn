class AddFirstnameToAccesstokens < ActiveRecord::Migration
  def change
    add_column :access_tokens, :firstname, :string
  end
end
