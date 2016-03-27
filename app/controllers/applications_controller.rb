class ApplicationsController < ApplicationController
  before_action :ensure_accepting_applications
  before_action :require_applicant_user
  before_action :ensure_own_application

  def show
    @user = current_user
  end

  def edit
    @application_form = ApplicationForm.new(current_user)
  end

  def update
    @application_form = ApplicationForm.new(current_user)

    if params['save']
      @application_form.save_draft(filtered_params)
    elsif params['submit']
      @application_form.submit(filtered_params)
    end

    if @application_form.errors.any?
      flash[:error] = @application_form.flash_message
    else
      flash[:notice] = @application_form.flash_message
    end

    render :edit
  end

  private

  def ensure_own_application
    unless current_user.application.id.to_s == params.require(:id)
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

  def filtered_params
    params.require(:application_form).permit(:name, :email, application_attributes)
  end

  def application_attributes
    [
      :agreement_coc, :agreement_attendance, :agreement_deadline,
      :why_andconf, :feminism, :programming_experience, :diversity, :scholarship,
      :travel_stipend, :attend_last_year, :referral_code
    ]
  end

  def ensure_accepting_applications
    unless Configurable[:accepting_applications]
      flash['notice'] = "AndConf isn't currently accepting applications. Join our #{ view_context.link_to "general interest mailing list", MAILING_LIST, target: "_blank" } to be notified when applications are open again.".html_safe
      redirect_to root_path
    end
  end
end
