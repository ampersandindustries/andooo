class SignupReminderMailer < ActionMailer::Base

  default from: "AndConf <#{INFO_EMAIL}>"
  
  def three_day_reminder(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Get your spot at AndConf today!"
    )
  end

  def six_day_reminder(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Are you still interested in attending AndConf?"
    )
  end

  def nine_day_reminder(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Last chance to claim your spot at AndConf 2016"
    )
  end
end
