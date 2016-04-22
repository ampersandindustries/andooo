class Volunteers::UsersController < Volunteers::VolunteersController
  def index
    @all_attendees = User.all_attendees
    @just_attendees = User.attendees
  end

  def show
    @user = User.all_attendees.find(params.require(:id))
  end
end
