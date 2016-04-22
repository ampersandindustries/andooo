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
    app = User.where(is_scholarship: true).first.application
    ApplicationsMailer.approved(app)
  end
end
