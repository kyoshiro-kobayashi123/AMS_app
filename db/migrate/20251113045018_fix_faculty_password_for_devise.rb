class FixFacultyPasswordForDevise < ActiveRecord::Migration[7.0]
  def change
    # 不要なpasswordカラムを削除
    remove_column :faculties, :password, :string

    # Deviseが必要とするカラムを追加
    add_column :faculties, :email, :string, default: "", null: false
    add_column :faculties, :encrypted_password, :string, default: "", null: false

    add_index :faculties, :email, unique: true
  end
end
