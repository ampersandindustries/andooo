class ApplicationsMailer < ActionMailer::Base
  default from: "AndConf <#{ATTEND_EMAIL}>"

  def submitted(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Thanks for applying to attend AndConf!"
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

  def declined(application)
    @user = application.user
    mail(
      to: INFO_EMAIL,
      subject: "#{@user.name} has declined to attend AndConf :("
    )
  end
end
