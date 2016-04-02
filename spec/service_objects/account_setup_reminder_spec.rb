require "spec_helper"

describe AccountSetupReminder do
  describe "#send_emails" do
    before { ActionMailer::Base.deliveries = [] }

    let(:deliveries) { ActionMailer::Base.deliveries }
    let(:users) { User.has_not_confirmed_attendance }
    let!(:applicant) { create(:approved_application).user }
    let!(:other_attendee) { create(:confirmed_application).user }

    subject { AccountSetupReminder.new(users).send_emails }

    context "with no reminders needed" do
      it "sends no emails" do
        subject
        expect(deliveries.count).to eq 0
      end
    end

    context "with one 3 day reminder" do
      before do
        applicant.application.update_column(:processed_at, 3.days.ago)
        other_attendee.application.update_column(:processed_at, 3.days.ago)
      end

      it "sends 1 email" do
        subject
        expect(deliveries.count).to eq 1
      end
    end

    context "with one 7 day reminder" do
      before do
        applicant.application.update_column(:processed_at, 7.days.ago)
        other_attendee.application.update_column(:processed_at, 7.days.ago)
      end

      it "sends 1 email" do
        subject
        expect(deliveries.count).to eq 1
      end
    end

    context "with one 14 day reminder" do
      before do
        applicant.application.update_column(:processed_at, 14.days.ago)
        other_attendee.application.update_column(:processed_at, 14.days.ago)
      end

      it "sends 1 email" do
        subject
        expect(deliveries.count).to eq 1
      end
    end

    context "with one 21 day reminder" do
      before do
        applicant.application.update_column(:processed_at, 21.days.ago)
        other_attendee.application.update_column(:processed_at, 21.days.ago)
      end

      it "sends 1 email" do
        subject
        expect(deliveries.count).to eq 1
      end
    end
  end
end
