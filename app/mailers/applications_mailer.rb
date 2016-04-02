class ApplicationsMailer < ActionMailer::Base
  default from: "Double Union <#{INFO_EMAIL}>"

  def submitted(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Thanks for applying to Double Union!"
    )
  end

  def approved(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Please join us at AndConf 2016"
    )
  end

  def confirmed(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Attendance at AndConf 2016 confirmed!"
    )
  end

  def votes_threshold(application)
    @user = application.user
    @application = application
    mail(
      to: INFO_EMAIL,
      subject: "A Double Union application hit the votes threshold!"
    )
  end
end
