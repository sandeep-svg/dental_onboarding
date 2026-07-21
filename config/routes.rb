# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user, ->(u) { u.admin_or_recruiter? } do
    root to: "admin/candidates#index", as: :admin_root
  end

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  root to: redirect("/users/sign_in")

  scope :onboarding, as: :onboarding do
    get  "upload_cv",          to: "onboarding#upload_cv"
    post "upload_cv",          to: "onboarding#process_cv"
    post "continue_manual",    to: "onboarding#continue_manual"
    get  "review",             to: "onboarding#review"
    patch "review",            to: "onboarding#save_profile"
    get  "parsing_status",     to: "onboarding#parsing_status"
    post "retry_parsing",      to: "onboarding#retry_parsing"
  end

  namespace :admin do
    resources :candidates, only: [:index, :show]
  end
end
