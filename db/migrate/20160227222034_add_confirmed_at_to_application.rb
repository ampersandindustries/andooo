class AddConfirmedAtToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :confirmed_at, :timestamp
  end
end
