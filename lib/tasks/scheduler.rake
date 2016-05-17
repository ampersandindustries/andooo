namespace :scheduler do
  desc "Send reminder emails to members who haven't set up their accounts"
  task setup_reminder_emails: :environment do
    AccountSetupReminder.new(User.has_not_confirmed_attendance).send_emails
  end
end
