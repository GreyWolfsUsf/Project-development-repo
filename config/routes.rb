Rails.application.routes.draw do
  # Root route
  root "home#index"
  
  # Authentication routes
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  
  # Registration routes
  get "/signup", to: "users#new"
  post "/signup", to: "users#create"
  
  # User profile
  get "/account", to: "users#show"
  get "/account/edit", to: "users#edit"
  patch "/account", to: "users#update"
  
  # Ride requests
  resources :ride_requests do
    member do
      patch :accept
      patch :start
      patch :complete
      patch :cancel
    end
    collection do
      get :history
    end
  end
  
  # Locations
  resources :locations, only: [:index, :show]
  
  # Notifications
  resources :notifications, only: [:index, :show] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end
  
  # Admin routes
  namespace :admin do
    root to: "dashboard#index"
    resources :users
    resources :ride_requests
    resources :locations
  end
  
  # Driver routes
# Add these to your routes.rb file
  namespace :driver do
    root to: "dashboard#index"
    resources :ride_requests, only: [:index, :show, :update]
  end
end