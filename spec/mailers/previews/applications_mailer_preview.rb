class ApplicationsMailerPreview < ActionMailer::Preview

  def submitted
    ApplicationsMailer.submitted(Application.first)
  end

  def approved
    User.first.update(is_scholarship: false, travel_stipend: nil)
    ApplicationsMailer.approved(Application.first)
  end

  def confirmed
    ApplicationsMailer.confirmed(Application.first)
  end

  def approved_scholarship_and_travel_stipend
    User.first.update(is_scholarship: true, travel_stipend: "300")
    ApplicationsMailer.approved(User.first.application)
  end

  def approved_scholarship_no_travel_stipend
    User.first.update(is_scholarship: true, travel_stipend: nil)
    ApplicationsMailer.approved(User.first.application)
  end

  def approved_travel_stipend_no_scholarship
    User.first.update!(is_scholarship: false, travel_stipend: "150")
    ApplicationsMailer.approved(User.first.application)
  end
end
