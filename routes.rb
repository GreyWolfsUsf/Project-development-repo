# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Add this route for estimating ride times
      get 'estimated_times', to: 'estimated_times#calculate'
    end
  end
end