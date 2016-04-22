class SignupReminderMailerPreview < ActionMailer::Preview
  def three_day_reminder
    SignupReminderMailer.three_day_reminder(User.first)
  end

  def six_day_reminder
    SignupReminderMailer.six_day_reminder(User.first)
  end

  def nine_day_reminder
    SignupReminderMailer.nine_day_reminder(User.first)
  end
end
