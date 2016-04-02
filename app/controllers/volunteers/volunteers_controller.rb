class Volunteers::VolunteersController < ApplicationController
  before_action :authenticate_application_reviewer!

  protected

  def members_page?
    true
  end

  def authenticate_application_reviewer!
    unless logged_in? && current_user.application_reviewer?
      redirect_to root_url
    end
  end
end
