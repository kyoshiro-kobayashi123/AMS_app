Rails.application.routes.draw do
  get "home/top"
  devise_for :students, controllers: {
    sessions: 'students/sessions'
  }
  
  devise_for :faculties, controllers: {
    sessions: 'faculties/sessions'
  }

  #deviseのログイン機能を起動したときにのルートパスを設定
  devise_scope :student do
    root "home#top"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :schedules, only: [:index]
  # ルートURLをスケジュール一覧に設定
  # root to: 'schedules#index'
  # 追加コード
  resources :attendances, only: [:index, :new, :create]

  # 教員用のルーティング (faculties/attendances#index などにアクセス)
  namespace :faculties do
    resources :attendances, only: [:index, :update] do
    end
  end
end
