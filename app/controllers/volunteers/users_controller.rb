class Volunteers::UsersController < Volunteers::MembersController
  def index
    @all_members = User.all_members.order_by_state
  end

  def show
    @user = User.all_members.find(params.require(:id))
  end
end
