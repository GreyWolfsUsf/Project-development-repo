class LocationsController < ApplicationController
    def index
      @locations = Location.where(active: true).order(:name)
      
      respond_to do |format|
        format.html
        format.json { render json: @locations }
      end
    end
    
    def show
      @location = Location.find(params[:id])
      
      respond_to do |format|
        format.html
        format.json { render json: @location }
      end
    end
  end