class AddVariousFieldsToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :scholarship, :text
    add_column :applications, :travel_stipend, :text
    add_column :applications, :attend_last_year, :boolean
    add_column :applications, :referral_code, :text
  end
end
