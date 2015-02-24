class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.string :plastname
      t.string :pfirstname
      t.string :clastname
      t.string :cfirstname
      t.string :company

      t.timestamps
    end
  end
end
