class AdminController < ApplicationController
  before_filter :ensure_admin

  def applications
    @to_approve = Application.to_approve
    @to_reject = Application.to_reject
    @unknown = Application.not_enough_info
  end

  def approve
    application = Application.find(application_params[:id])
    application.approve
    if application.save
      flash[:message] = "Successfully approved #{application.user.name}!"
      redirect_to admin_applications_path
    else
      flash[:error] = "Whoops! #{application.errors.full_messages.to_sentence}"
      render :applications
    end
  end

  def reject
    application = Application.find(application_params[:id])
    application.reject
    if application.save
      flash[:message] = "Successfully rejected #{application.user.name}."
      redirect_to admin_applications_path
    else
      flash[:error] = "Whoops! #{application.errors.full_messages.to_sentence}"
      render :applications
    end
  end

  def save_membership_note
    user = User.find(user_params[:id])
    user.membership_note = user_params[:membership_note]

    respond_to do |format|
      if user.save
        format.json { render json: { user_id: user.id } }
      else
        format.json { render json: { user_id: user.id } }
      end
    end
  end

  protected

  def members_page?
    false
  end

  private

  def application_params
    params.require(:application).permit(:id)
  end

  def user_params
    params.require(:user).permit(:id, :membership_note)
  end

  def find_member
    @user = User.find(params[:user][:id])
  end
end
