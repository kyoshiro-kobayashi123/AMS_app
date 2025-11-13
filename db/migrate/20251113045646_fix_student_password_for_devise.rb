class FixStudentPasswordForDevise < ActiveRecord::Migration[7.0]
  def change
    # 不要なpasswordカラムを削除
    remove_column :students, :password, :string

    # Devise用のカラムを追加
    add_column :students, :email, :string, default: "", null: false
    add_column :students, :encrypted_password, :string, default: "", null: false

    add_index :students, :email, unique: true
  end
end
