class Student < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :absences, dependent: :destroy

  # Deviseの設定から `:email` を削除し、`student_number` を認証キーに指定
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :recoverable, :rememberable,
         authentication_keys: [:student_number]

  # validatableの代わりにカスタムバリデーション
  validates :student_number, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  private

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end
