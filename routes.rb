# config/routes.rb
Rails.application.routes.draw do
  # Assuming you already have other routes
  
  namespace :api do
    namespace :v1 do
      resources :ride_requests, only: [:create, :show, :update] do
        member do
          post :cancel
        end
      end
    end
  end
end