class AddLurlToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :lurl, :string
  end
end
