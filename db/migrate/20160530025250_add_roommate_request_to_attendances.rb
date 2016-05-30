class AddRoommateRequestToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :roommate_request, :text
  end
end
