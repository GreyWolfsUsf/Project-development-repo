class SessionsController < ApplicationController
    skip_before_action :require_login, only: [:new, :create]
    
    def new
      redirect_to root_path if current_user
    end
    
    def create
      user = User.find_by(email: params[:email])
      
      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        user.update(last_login_at: Time.current)
        
        redirect_to after_login_path(user), notice: "Successfully logged in!"
      else
        flash.now[:alert] = "Invalid email or password"
        render :new, status: :unprocessable_entity
      end
    end
    
    def destroy
      session[:user_id] = nil
      redirect_to login_path, notice: "Successfully logged out!"
    end
    
    private
    
    def after_login_path(user)
      case user.role
      when "admin"
        admin_root_path
      when "driver"
        driver_root_path
      else
        root_path
      end
    end
  end