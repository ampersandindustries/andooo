class AddEventIdToAttendances < ActiveRecord::Migration
  class Attendance < ActiveRecord::Base; end
  class Event < ActiveRecord::Base; end

  def up
    add_column :attendances, :event_id, :integer

    add_index :attendances, [:event_id, :user_id], unique: true

    Event.create(name: "andconf2016")
    Attendance.update_all(event_id: Event.where(name: "andconf2016").first.id)
  end

  def down
    remove_column :attendances, :event_id
    Event.where(name: "andconf2016").first.destroy
  end
end
