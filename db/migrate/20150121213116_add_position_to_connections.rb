class AddPositionToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :position, :string
  end
end
