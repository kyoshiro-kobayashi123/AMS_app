class Student < ApplicationRecord
  devise :database_authenticatable, :registerable,
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
