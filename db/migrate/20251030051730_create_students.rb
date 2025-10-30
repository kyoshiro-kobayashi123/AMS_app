class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.string :student_number, null:false,  limit: 20
      t.string :password, null:false
      t.string :name, null:false,  limit: 100
      t.date :birth_date
      t.string :address
      t.string :emergency_contact, limit: 20

      t.timestamps
    end
  end
end
