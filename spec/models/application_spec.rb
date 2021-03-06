require 'spec_helper'

describe Application do
  describe "validations" do
    it { is_expected.to validate_presence_of :user_id }
  end

  describe "#submit" do
    let(:application) { create(:unsubmitted_application) }

    it "sends an email to the applicant" do
      expect { application.submit }.to change(ActionMailer::Base.deliveries, :count).by(1)
      expect(application.reload.submitted_at).to be_present
    end
  end

  describe "#approve" do
    let(:application) { create(:approvable_application) }
    let(:user) { application.user }

    subject { application.approve }

    it "sends an email to the applicant" do
      expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "marks processed_at" do
      subject
      expect(application.reload.processed_at).to be_present
    end

    it "marks the application as approved" do
      expect { subject }.to change { application.state }.from("submitted").to("approved")
    end
  end

  describe "#confirm" do
    let(:application) { create(:approved_application) }

    subject { application.confirm }

    it "marks confirmed at" do
      subject
      expect(application.reload.confirmed_at).to be_present
    end

    it "sends the user a confirmation email" do
      expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "marks the user as an attendee" do
      expect { subject }.to change { application.user.state }.from("applicant").to("attendee")
    end
  end

  describe 'with an approvable application' do
    let(:application) { create(:application) }

    before do
      expect(application).to receive_message_chain(:yes_votes, :count) { 6 }
      expect(application).to receive_message_chain(:no_votes, :count) { 0 }
    end

    it "should be approvable" do
      expect(application.approvable?).to be_truthy
    end
  end

  describe 'with a rejectable application' do
    let(:application) { create(:application) }

    before do
      allow(application).to receive_message_chain(:yes_votes, :count)
      allow(application).to receive_message_chain(:no_votes, :count) { 2 }
    end

    it "should be rejectable" do
      expect(application.rejectable?).to be_truthy
    end
  end

  describe "#decline" do
    subject { application.decline }

    context "application is approved" do
      let(:application) { create(:approved_application) }

      it "sends the organizers a declined email" do
        expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it "doesn't change the user state" do
        expect { subject }.to_not change { application.user.state }
      end
    end

    context "application is confirmed" do
      let(:application) { create(:confirmed_application) }

      it "doesn't send the organizers a declined email" do
        expect { subject }.to_not change(ActionMailer::Base.deliveries, :count)
      end

      it "returns the user to the applicant state" do
        expect { subject }.to change { application.user.state }.from("attendee").to("applicant")
      end
    end
  end
end
