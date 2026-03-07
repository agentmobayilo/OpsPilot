require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq dashboard (protect with auth before production use).
  mount Sidekiq::Web => "/sidekiq"

  get "settings", to: "home#settings"
  delete "oauth_connections/:provider", to: "oauth_connections#destroy", as: :oauth_connection

  root "home#index"
end
