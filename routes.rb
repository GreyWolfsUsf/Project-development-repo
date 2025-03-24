Rails.application.routes.draw do
  # Login routes
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # Root route
  root 'sessions#new'
end