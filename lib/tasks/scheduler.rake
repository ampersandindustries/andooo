namespace :scheduler do
  desc "Send reminder emails to new members who haven't set up their accounts"
  task setup_reminder_emails: :environment do
    AccountSetupReminder.new(User.new_members).send_emails
  end
end
