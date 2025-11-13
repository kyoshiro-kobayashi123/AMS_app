class RemoveEmailFromStudents < ActiveRecord::Migration[8.0]
  def change
    remove_column :students, :email, :string
  end
end
