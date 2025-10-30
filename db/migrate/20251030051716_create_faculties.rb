class CreateFaculties < ActiveRecord::Migration[8.0]
  def change
    create_table :faculties do |t|
      t.string :faculty_number, null:false, limit: 20
      t.string :password, null:false
      t.string :name, null:false, limit: 20

      t.timestamps
    end
  end
end
