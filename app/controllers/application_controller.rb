class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:faculty_number])
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(Faculty)
      faculties_attendances_path   # 教員ログイン後の遷移先
    elsif resource.is_a?(Student)
      new_attendance_path          # 学生ログイン後の遷移先（テスト）
    else
      super
    end
  end
end
