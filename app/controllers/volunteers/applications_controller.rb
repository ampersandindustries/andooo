class Volunteers::ApplicationsController < Volunteers::VolunteersController

  def index
    @applicants_submitted = User.with_submitted_application
    @requested_scholarship_count = User.requested_scholarship.count
    @requested_stipend_count = User.requested_stipend.count
  end

  def show
    @application = Application.find(params.require(:id))
    @comments = @application.comments.order(:created_at)

    unless @application.submitted?
      flash[:error] = 'This application is not currently visible.'
      redirect_to volunteers_root_path and return
    end

    @user = @application.user
    @vote = current_user.vote_for(@application) || Vote.new
  end

  private

  def application_params
    params.require(:application_id)
  end
end

