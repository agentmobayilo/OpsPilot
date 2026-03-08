require "sidekiq/web"

Rails.application.routes.draw do
  mount_avo
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  namespace :api do
    resources :email_threads, only: [] do
      member do
        patch :approve_draft
        patch :complete_action
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq dashboard (protect with auth before production use).
  mount Sidekiq::Web => "/sidekiq"

  get "settings", to: "home#settings"
  patch "settings", to: "home#update_preferences"

  patch "oauth_connections/:id/activate", to: "oauth_connections#activate", as: :activate_oauth_connection
  delete "oauth_connections/:id", to: "oauth_connections#destroy", as: :oauth_connection

  post "sync_inbox", to: "home#sync_inbox"

  root "home#index"
end
