require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    it 'renders the login page' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'redirects to the root path' do
        allow_any_instance_of(SessionsController).to receive(:authenticate_with_usf).and_return({ success: true, user_id: 1 })
        post :create, params: { email: 'user@example.com', password: 'password123' }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid credentials' do
      it 'renders the login page with an error' do
        allow_any_instance_of(SessionsController).to receive(:authenticate_with_usf).and_return({ success: false, error: 'Invalid email or password' })
        post :create, params: { email: 'user@example.com', password: 'wrongpassword' }
        expect(response).to render_template(:new)
        expect(flash[:error]).to eq('Invalid email or password')
      end
    end
  end
end