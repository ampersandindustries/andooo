class AddPronounsToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :pronouns, :text
  end
end
