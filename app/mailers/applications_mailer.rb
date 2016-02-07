class ApplicationsMailer < ActionMailer::Base
  default from: "Double Union <#{INFO_EMAIL}>"

  def confirmation(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Thanks for applying to Double Union!"
    )
  end

  def notify_members(application)
    member_emails = User.all_members.pluck(:email).compact
    @applicant = application.user
    mail(
      to: INFO_EMAIL,
      bcc: member_emails,
      subject: "New Double Union application submitted"
    )
  end

  def approved(application)
    @user = application.user
    mail(
      to: @user.email,
      subject: "Welcome to Double Union!!!"
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

  def member_access(application)
    @user = application.user
    @application = application
    mail(
      to: @user.email,
      subject: "You now have Double Union access!"
    )
  end
end
