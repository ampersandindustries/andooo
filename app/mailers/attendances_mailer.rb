class AttendancesMailer < ActionMailer::Base
  add_template_helper(UsersHelper)

  default from: "AndConf <#{ATTEND_EMAIL}>"

  def deadline(attendance)
    @attendance = attendance

    mail(
      to: attendance.user.email,
      subject: "Finalize your AndConf details by #{Configurable[:attendance_updates_close_date]}"
    )
  end

  def transportation_confirmation(attendance)
    @attendance = attendance

    mail(
      to: attendance.user.email,
      subject: "Transportation Details for AndConf"
    )
  end
end
