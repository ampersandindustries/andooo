class Admin::AttendeesController < ApplicationController
  before_filter :ensure_admin

  def index
    @all_attendees = User.all_attendees

    respond_to do |format|
      format.html
      format.json { render json: @all_attendees.as_json }
    end
  end

  def update
    user = User.find(params[:id])

    if user.update_attributes!(user_params)
      flash[:message] = "#{user.name} updated."
    else
      flash[:message] = "Whoops! #{user.errors.full_messages.to_sentence}"
    end

    redirect_to admin_applications_path
  end

  def show
    @attendee = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:is_scholarship)
  end
end