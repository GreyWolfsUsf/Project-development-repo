# spec/support/authentication_helpers.rb
module AuthenticationHelpers
    def login_as(user)
      post login_path, params: { email: user.email, password: 'password' }
    end
  end