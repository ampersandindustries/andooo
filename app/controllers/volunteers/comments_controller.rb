class Volunteers::CommentsController < Volunteers::VolunteersController
  def create
    application = Application.find(application_id_param)
    comment = Comment.new(comment_params)
    comment.user = current_user

    if comment.save
      flash[:notice] = 'Comment saved'
    else
      flash[:error] = 'Comment not saved'
    end

    redirect_to volunteers_application_path(application)
  end

  private

  def application_id_param
    params.require(:comment).require(:application_id)
  end

  def comment_params
    params.require(:comment).permit([:body, :application_id])
  end
end
