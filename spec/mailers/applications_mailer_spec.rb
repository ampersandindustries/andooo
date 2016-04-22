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
end
