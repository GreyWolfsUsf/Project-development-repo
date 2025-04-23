class UsersController < ApplicationController
    skip_before_action :require_login, only: [:new, :create]
    before_action :set_user, only: [:show, :edit, :update]
    before_action :authorize_user, only: [:edit, :update]
    
    def new
      redirect_to root_path if current_user
      @user = User.new
    end
    
    def create
      @user = User.new(user_params)
      @user.role = :student  # Ensure new users are always students
      
      if @user.save
        session[:user_id] = @user.id
        redirect_to root_path, notice: "Account created successfully!"
      else
        render :new, status: :unprocessable_entity
      end
    end
    
    def show
      # Show account details
    end
    
    def edit
      # Edit account form
    end
    
    def update
      if @user.update(update_user_params)
        redirect_to account_path, notice: "Account updated successfully!"
      else
        render :edit, status: :unprocessable_entity
      end
    end
    
    private
    
    def set_user
      @user = current_user
    end
    
    def authorize_user
      unless @user == current_user
        redirect_to root_path, alert: "You are not authorized to perform this action."
      end
    end
    
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, 
                                   :first_name, :last_name, :u_number, :phone)
    end
    
# app/controllers/users_controller.rb
    def update_user_params
      params.require(:user).permit(:password, :password_confirmation, :phone, :avatar)
    end
  end