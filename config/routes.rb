Rails.application.routes.draw do
  # -------------------------------------------------------------------------
  # 1. トップページ
  # -------------------------------------------------------------------------
  root "home#top"

  # -------------------------------------------------------------------------
  # 2. 認証機能 (Devise)
  # -------------------------------------------------------------------------
  # 学生 (Student) 用
  devise_for :students, controllers: {
    sessions:      'students/sessions',
    registrations: 'students/registrations',
    passwords:     'students/passwords',
    confirmations: 'students/confirmations'
  }

  # 教員 (Faculty) 用
  devise_for :faculties, controllers: {
    sessions:      'faculties/sessions',
    registrations: 'faculties/registrations',
    passwords:     'faculties/passwords',
    confirmations: 'faculties/confirmations',
    unlocks:       'faculties/unlocks',
  }

  # -------------------------------------------------------------------------
  # 3. 共通・学生向け機能
  # -------------------------------------------------------------------------
  
  # 出席登録 (学生用)
  # コントローラー: AttendancesController (create後にnewへリダイレクト)
  resources :attendances, only: [:index, :new, :create]

  # 欠席届 (学生用)
  # コントローラー: AbsencesController
  resources :absences, only: [:index, :create]

  # 時間割 (スケジュール)
  # コントローラー: SchedulesController
  # ※Viewにedit/newへのリンクがあるため、コントローラー未実装でもルート定義は必須
  resources :schedules, only: [:index, :new, :create, :edit, :update]

  # -------------------------------------------------------------------------
  # 4. 教員(管理者)専用機能 (名前空間: faculties)
  # -------------------------------------------------------------------------
  # URL: /faculties/attendances など
  namespace :faculties do
    # コントローラー: Faculties::AttendancesController
    resources :attendances, only: [:index, :update]
  end

  # -------------------------------------------------------------------------
  # 5. Rails 8 ヘルスチェック & PWA
  # -------------------------------------------------------------------------
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
