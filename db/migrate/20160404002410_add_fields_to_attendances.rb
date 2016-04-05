class AddFieldsToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :badge_name, :text
    add_column :attendances, :dietary_restrictions, :text
    add_column :attendances, :dietary_additional_info, :text
    add_column :attendances, :twitter_handle, :text
    add_column :attendances, :sleeping_preference, :text
    add_column :attendances, :staying_sunday_night,  :text
    add_column :attendances, :flying_in, :text
    add_column :attendances, :agree_to_coc, :boolean
    add_column :attendances, :attend_entire_conference, :boolean
    add_column :attendances, :interested_in_volunteering, :boolean
    add_column :attendances, :transport_to_venue, :text
    add_column :attendances, :transport_from_venue, :text
    add_column :attendances, :accept_trails_and_pool_risk, :boolean    
  end
end
