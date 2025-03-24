class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    # Render the login page
  end

  def create
    email = params[:email]
    password = params[:password]

    # Validate input
    if email.blank? || password.blank?
      flash[:error] = "Email and password are required."
      render :new
      return
    end

    # Authenticate with USF's API
    response = authenticate_with_usf(email, password)

    if response[:success]
      # Store user data in session or generate a JWT token
      session[:user_id] = response[:user_id]
      redirect_to root_path, notice: "Logged in successfully!"
    else
      flash[:error] = response[:error]
      render :new
    end
  end

  def destroy
    # Log out the user
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out successfully!"
  end

  private

  def authenticate_with_usf(email, password)
    # Replace with actual USF API endpoint and logic
    url = "https://usf-auth-api.example.com/authenticate"
    body = { email: email, password: password }

    response = HTTParty.post(url, body: body.to_json, headers: { 'Content-Type' => 'application/json' })

    if response.success?
      { success: true, user_id: response['user_id'] }
    else
      { success: false, error: "Invalid email or password." }
    end
  rescue StandardError => e
    { success: false, error: "An error occurred: #{e.message}" }
  end
end