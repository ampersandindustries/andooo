class DonationsMailer < ActionMailer::Base

  def donation_receipt(email, amount)
    @amount = amount

    mail(
      to: email,
      from: INFO_EMAIL,
      bcc: INFO_EMAIL,
      subject: "Thank you for your donation to AndConf!"
    )
  end
end
