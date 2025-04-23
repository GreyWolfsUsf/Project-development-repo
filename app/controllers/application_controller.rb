class ApplicationController < ActionController::Base
  before_action :require_login
  helper_method :current_user, :logged_in?
  
  private
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end
  
  def require_student
    unless current_user&.student?
      flash[:alert] = "Access denied. Student privileges required."
      redirect_to root_path
    end
  end
  
  def require_driver
    unless current_user&.driver?
      flash[:alert] = "Access denied. Driver privileges required."
      redirect_to root_path
    end
  end
  
  def require_admin
    unless current_user&.admin?
      flash[:alert] = "Access denied. Admin privileges required."
      redirect_to root_path
    end
  end
end