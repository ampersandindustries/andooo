class ApiController < ApplicationController

  def configurations
    respond_to do |format|
      format.json { render json: {
        configurations: {
          accepting_applications: Configurable[:accepting_applications]
        }
      } }
    end
  end
end
