class Faculty < ApplicationRecord
  has_many :lessons, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         authentication_keys: [:faculty_number] # 認証キーを faculty_number に指定
  
  # emailのカラムがないため、emailのバリデーションをスキップする
  def email_required?
    false
  end
  
  def email_changed?
    false
  end
  
  # update_without_password利用時にemailなしでもバリデーションを通過させる
  def will_save_change_to_email?
    false
  end
end