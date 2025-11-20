class AddEncryptedPasswordToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :encrypted_password, :string, null: false, default: ""
  end
end
