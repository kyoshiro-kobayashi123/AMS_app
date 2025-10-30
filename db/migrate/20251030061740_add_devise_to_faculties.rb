# db/migrate/xxxxxxxxxx_devise_create_faculties.rb (修正後)
 
class AddDeviseToFaculties < ActiveRecord::Migration[8.0] # Railsのバージョンに合わせて
  def change
    change_table :faculties do |t|
      ## Database authenticatable
      # t.string :email,              null: false, default: "" # <- コメントアウト/削除
      # ログインIDとして faculty_number を使用
      # t.string :faculty_number,       null: false, default: ""
      # t.string :encrypted_password, null: false, default: ""
 
      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
 
      ## Rememberable
      t.datetime :remember_created_at
      # (他のモジュールは必要に応じて追加してください)
    end
 
    # faculty_number をログイン用のユニークなインデックスにする
    add_index :faculties, :faculty_number,       unique: true
    add_index :faculties, :reset_password_token, unique: true
    # 既存の faculty_number カラムに NOT NULL 制約を追加
    change_column_null :faculties, :faculty_number, false
  end
end