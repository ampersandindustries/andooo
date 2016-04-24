class ApplicationsMailerPreview < ActionMailer::Preview

  def submitted
    ApplicationsMailer.submitted(Application.first)
  end

  def approved
    ApplicationsMailer.approved(Application.first)
  end

  def confirmed
    ApplicationsMailer.confirmed(Application.first)
  end

  def approved_scholarship
    User.first.update(is_scholarship: true)
    ApplicationsMailer.approved(User.first.application)
  end
end
