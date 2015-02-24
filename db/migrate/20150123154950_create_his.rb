class CreateHis < ActiveRecord::Migration
  def change
    create_table :his do |t|
      t.string :s

      t.timestamps
    end
  end
end
