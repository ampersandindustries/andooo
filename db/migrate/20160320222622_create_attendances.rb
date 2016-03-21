class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.references :user
      t.string :gender
      t.timestamps
    end
  end
end
