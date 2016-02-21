class ApplicationsController < ApplicationController
  before_action :ensure_accepting_applications
  before_action :require_applicant_user

  before_action :set_user,               only: [:show, :edit, :update]
  before_action :ensure_own_application, only: [:show, :edit, :update]

  def new
    redirect_to edit_application_path(current_user.application)
  end

  def show
  end

  def edit
  end

  def update
    unless @user.update_attributes(user_params)
      app_errors =  @user.application.errors.full_messages.to_sentence
      user_errors = @user.errors.full_messages.to_sentence
      errors = user_errors + app_errors
      flash[:error] = "Application not saved: #{errors}"
      render action: :edit, id: @user.application.id and return
    end

    case commit_action
    when :submit
      begin
        @user.application.submit!
        flash[:notice] = 'Application submitted!'
      rescue StateMachine::InvalidTransition
        errors = @user.application.errors.full_messages.to_sentence
        flash[:error] = "Application not submitted: #{errors}"
      end
    when :save
      flash[:notice] = 'Application saved'
    end
    redirect_to action: :edit, id: @user.application.id
  end

  private

  def set_user
    @user = current_user
  end

  def ensure_own_application
    unless @user.application.id.to_s == params.require(:id)
      redirect_to :root
    end
  end

  def commit_action
    if params['save']
      :save
    elsif params['submit']
      :submit
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, application_attributes: application_attributes)
  end

  def application_attributes
    [
      :id, :agreement_coc, :agreement_attendance, :agreement_deadline,
      :why_andconf, :feminism, :programming_experience, :diversity
    ]
  end

  def ensure_accepting_applications
    unless Configurable[:accepting_applications]
      flash['notice'] = "AndConf isn't currently accepting applications. Join our #{ view_context.link_to "general interest mailing list", MAILING_LIST, target: "_blank" } to be notified when applications are open again.".html_safe
      redirect_to root_path
    end
  end
end
