# spec/requests/api/v1/wait_times_controller_spec.rb
#FR-03 #31
#Test file for FR-03 #31

require 'rails_helper'

RSpec.describe 'WaitTimes API', type: :request do
  describe 'GET /api/v1/wait_time/:location_id' do
    context 'with a valid location_id' do
      it 'returns the estimated wait time' do
        get '/api/v1/wait_time/lib'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['location_id']).to eq('lib')
        expect(json['estimated_wait_time_minutes']).to eq(5)
        expect(json['status']).to eq('success')
      end
    end

    context 'with an invalid location_id' do
      it 'returns an error message' do
        get '/api/v1/wait_time/invalid_location'

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)

        expect(json['error']).to eq('Invalid location ID or wait time unavailable')
        expect(json['status']).to eq('error')
      end
    end
  end
end
