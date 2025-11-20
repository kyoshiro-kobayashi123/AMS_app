class RemovePasswordNotNullConstraint < ActiveRecord::Migration[8.0]
  def change
    # Deviseではpasswordは仮想属性で、encrypted_passwordに保存される
    # そのため、元のpasswordカラムのNOT NULL制約を削除
    change_column_null :faculties, :password, true
    change_column_null :students, :password, true
  end
end
