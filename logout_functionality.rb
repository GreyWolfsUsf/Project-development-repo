# Add to your routes.rb file
# config/routes.rb
Rails.application.routes.draw do
  # ... other routes
  
  # Logout route
  delete 'logout', to: 'sessions#destroy'
  # Alternative option for simple GET logout
  get 'logout', to: 'sessions#destroy'
end

# Sessions Controller
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  # ... other methods like create for login
  
  def destroy
    # Clear the user session
    reset_session
    
    # If using Devise gem
    # sign_out current_user
    
    # If using USF SSO integration, you might need to redirect to their logout endpoint
    # Redirect to the SSO logout URL if applicable
    # return redirect_to "https://usf-sso-endpoint.edu/logout?redirect_uri=#{root_url}"
    
    # For standard session-based auth
    session[:user_id] = nil
    
    # Flash message confirming logout
    flash[:notice] = "You have been successfully logged out"
    
    # Redirect to login page or homepage
    redirect_to root_path
  end
end

# Add logout link to your application layout or navigation
# app/views/layouts/_navigation.html.erb
<% if current_user %>
  <%= button_to "Logout", logout_path, method: :delete, class: "btn btn-outline-danger" %>
  <!-- Alternative for simple link -->
  <!-- <%= link_to "Logout", logout_path, class: "nav-link" %> -->
<% end %>

# If you're using the current_user helper, make sure it's defined
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  helper_method :current_user
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def authenticate_user!
    redirect_to login_path, alert: "Please log in to access this page" unless current_user
  end
end