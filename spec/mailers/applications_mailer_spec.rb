require 'spec_helper'

describe ApplicationsMailer do
  let(:application) { create(:application) }

  before do
    application.submit
  end

  describe 'when someone submits their application' do

    describe 'confirmation email' do
      let(:mail) { ApplicationsMailer.submitted(application) }

      it 'is sent to the applicant' do
        expect(mail.to).to eq([application.user.email])
      end

      it 'includes their name' do
        expect(mail.body).to include(application.user.name)
      end
    end
  end

  describe 'when someone is accepted' do
    before do
      application.approve
    end

    let(:mail) { ApplicationsMailer.approved(application) }

    it 'is sent to the applicant' do
      expect(mail.to).to include(application.user.email)
    end
  end

  describe 'when someone hits the vote threshold' do
    describe 'vote threshold email' do
      let(:approvable_application) { create(:approvable_application) }
      let(:rejectable_application) { create(:rejectable_application) }

      let(:approvable_mail) { approvable_application.votes_threshold_email }
      let(:rejectable_mail) { rejectable_application.votes_threshold_email }

      it 'is sent if application is approvable' do
        expect(approvable_mail.to).to include("info@andconf.io")
        expect(approvable_mail.body).to include(approvable_application.user.name)
        expect(approvable_mail.body).to include("approved")
      end

      it 'is sent if application is rejectable' do
        expect(rejectable_mail.to).to include("info@andconf.io")
        expect(rejectable_mail.body).to include(rejectable_application.user.name)
        expect(rejectable_mail.body).to include("rejected")
      end
    end
  end
end
