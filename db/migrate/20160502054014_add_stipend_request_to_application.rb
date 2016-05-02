class AddStipendRequestToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :stipend_request, :text
  end
end
