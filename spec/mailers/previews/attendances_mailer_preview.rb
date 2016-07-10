class AttendancesMailerPreview < ActionMailer::Preview

  def deadline
    AttendancesMailer.deadline(Attendance.first)
  end

  def deadline_with_special_diet
    attendance = Attendance.first
    attendance.dietary_additional_info = "I only eat chocolate cake!"
    AttendancesMailer.deadline(attendance)
  end
end
