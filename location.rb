# app/models/location.rb
class Location < ApplicationRecord
    validates :name, presence: true
  end
  
  # app/serializers/location_serializer.rb
  class LocationSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
  
  # app/controllers/locations_controller.rb
  class LocationsController < ApplicationController
    def index
      locations = Location.all
      render json: locations, status: :ok
    rescue => e
      render json: { error: "Unable to fetch locations: #{e.message}" }, status: :internal_server_error
    end
  end
  
  # config/routes.rb
  Rails.application.routes.draw do
    get '/locations', to: 'locations#index'
  end
  
  # db/seeds.rb
  Location.create(name: "Library")
  Location.create(name: "Engineering Building")
  Location.create(name: "Marshall Center")
  Location.create(name: "REC Center")
  
  # Run this to seed: rails db:seed
  
  # spec/requests/locations_spec.rb
  require 'rails_helper'
  
  RSpec.describe "Locations API", type: :request do
    describe "GET /locations" do
      before do
        Location.create!(name: "Library")
        Location.create!(name: "Marshall Center")
      end
  
      it "returns a list of locations" do
        get "/locations"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        expect(json.first).to include("name" => "Library")
      end
  
      it "handles errors gracefully" do
        allow(Location).to receive(:all).and_raise(StandardError.new("Something went wrong"))
        get "/locations"
        expect(response).to have_http_status(:internal_server_error)
        json = JSON.parse(response.body)
        expect(json["error"]).to include("Something went wrong")
      end
    end
  end
  