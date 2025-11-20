class AddEncryptedPasswordToFaculties < ActiveRecord::Migration[8.0]
  def change
    add_column :faculties, :encrypted_password, :string
  end
end
