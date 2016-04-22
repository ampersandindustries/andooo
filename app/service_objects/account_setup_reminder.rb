class AccountSetupReminder

  def initialize(users)
    @users = users
  end

  def send_emails
    @users.each do |user|
      processed_at = user.application.processed_at
      if processed_at < 2.days.ago && processed_at > 4.days.ago
        SignupReminderMailer.three_day_reminder(user).deliver_now
      elsif processed_at < 5.days.ago && processed_at > 7.days.ago
        SignupReminderMailer.six_day_reminder(user).deliver_now
      elsif processed_at < 8.days.ago && processed_at > 10.days.ago
        SignupReminderMailer.nine_day_reminder(user).deliver_now
      end
    end
  end
end
