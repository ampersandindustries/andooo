class AddTravelStipendToUsers < ActiveRecord::Migration
  def change
    add_column :users, :travel_stipend, :string
  end
end
