# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :current_user, :logged_in?
  
  def current_user
    if session[:user_id] && session[:expires_at] && session[:expires_at] > Time.current
      @current_user ||= User.find_by(id: session[:user_id])
    elsif session[:user_id]
      # Session expired, log the user out
      reset_session
      @current_user = nil
    end
  end
  
  def logged_in?
    !!current_user
  end
  
  private
  
  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this section"
      redirect_to login_path
    end
  end
end