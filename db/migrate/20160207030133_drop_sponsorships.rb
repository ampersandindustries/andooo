class DropSponsorships < ActiveRecord::Migration
  def up
    drop_table :sponsorships
    remove_column :applications, :stale_email_sent_at
  end

  def down
    create_table :sponsorships do |t|
      t.integer  :application_id
      t.integer  :user_id
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_column :applications, :stale_email_sent_at, :datetime
  end
end
