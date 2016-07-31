class AttendancesMailerPreview < ActionMailer::Preview

  def deadline
    AttendancesMailer.deadline(Attendance.first)
  end

  def deadline_with_special_diet
    attendance = Attendance.first
    attendance.dietary_additional_info = "I only eat chocolate cake!"
    AttendancesMailer.deadline(attendance)
  end

  def transportation_confirmation_driving
    attendance = Attendance.first
    attendance.transport_to_venue = "I will be driving myself or organizing carpooling via the doc or #transportation slack channel"
    attendance.transport_from_venue = "I will be driving myself or organizing carpooling via the doc or #transportation slack channel"
    AttendancesMailer.transportation_confirmation(attendance)
  end

  def transportation_confirmation_sunday_shuttle
    attendance = Attendance.first
    attendance.transport_to_venue =  "I will be taking the free shuttle leaving downtown San Francisco on FRIDAY, August 12th at 3pm"
    attendance.transport_from_venue = "I will be taking the free shuttle leaving St. Dorothy's Rest on SUNDAY, August 14th at 8pm, returning to downtown San Francisco"

    AttendancesMailer.transportation_confirmation(attendance)
  end

  def transportation_confirmation_monday_shuttle
    attendance = Attendance.first
    attendance.transport_to_venue =  "I will be taking the free shuttle leaving downtown San Francisco on FRIDAY, August 12th at 3pm"
    attendance.transport_from_venue = "I will be taking the free shuttle leaving St. Dorothy's Rest on MONDAY, August 15th at 10am, returning to downtown San Francisco"
    AttendancesMailer.transportation_confirmation(attendance)
  end

  def what_to_bring
    AttendancesMailer.what_to_bring(Attendance.first)
  end
end
