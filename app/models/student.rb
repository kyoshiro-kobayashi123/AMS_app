class Student < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :absences, dependent: :destroy

  # Deviseの設定から `:email` を削除し、`student_number` を認証キーに指定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         authentication_keys: [:student_number]

  # emailカラムを削除しているため、`validatable` は使用しない
  # 手動でバリデーションを追加する場合、例えばパスワードのバリデーション
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  private

  def password_required?
    # パスワードが変更されている場合のみバリデーション
    new_record? || !password.blank?
  end
end
