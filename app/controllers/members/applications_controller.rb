class Members::ApplicationsController < Members::MembersController

  def index
    @applicants_submitted = User.with_submitted_application
    @applicants_started   = User.with_started_application
  end

  def show
    @application = Application.find(params.require(:id))
    @comments = @application.comments.order(:created_at)

    unless @application.submitted?
      flash[:error] = 'This application is not currently visible.'
      redirect_to members_root_path and return
    end

    @user = @application.user
    @vote = current_user.vote_for(@application) || Vote.new
  end

  private

  def application_params
    params.require(:application_id)
  end
end

