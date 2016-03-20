class AttendancesController < ApplicationController
  before_action :require_approved_applicant

  def edit
    @user = current_user
  end

  def confirm
    @user = current_user

    # TODO: redirect to payments page if they aren't scholarship
    # TODO: redirect to details page if they are scholarship or have already paid
    # don't reconfirm people who have already been confirmed

    if @user.update!(user_params)
      @user.make_attendee! if @user.applicant?
      redirect_to details_attendances_path
    else
      render :edit
    end
  end

  def details
  end

  private

  def user_params
    params.permit(:gender)
  end

  def require_approved_applicant
    unless logged_in? && current_user.application.approved?
      redirect_to :root and return
    end
  end
end
