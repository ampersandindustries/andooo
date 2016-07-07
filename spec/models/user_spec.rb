require 'spec_helper'

describe User do
  describe "validations" do
    it { is_expected.to validate_presence_of :username }

    describe "email address" do
      let(:existing_user) { create :user }
      let(:new_user) { create :user }

      subject { new_user.update_attributes(email: existing_user.email) }

      it "doesn't allow duplication email addresses" do
        subject
        expect(new_user.valid?).to be_falsey
      end

      it "returns the correct error" do
        subject
        expect(new_user.errors.messages[:email].first).to include("has been taken.")
      end
    end
  end

  it 'should be in visitor state by default' do
    expect(User.new.state).to eq('visitor')
  end

  describe "#make_applicant" do
    subject { applicant.make_applicant }

    context "new applicant" do
      let(:applicant) { create(:visitor) }

      it "should transition from visitor to applicant" do
        expect { subject }.to change { applicant.state }.from("visitor").to("applicant")
      end
    end

    context "attendee declines to attend" do
      let(:applicant) { create(:attendee) }

      it "should transition from attendee to applicant" do
        expect { subject }.to change { applicant.state }.from("attendee").to("applicant")
      end
    end
  end

  describe "#make_attendee" do
    let(:applicant) { create(:applicant) }

    subject { applicant.make_attendee }

    it "should transition from applicant to attendee" do
      expect { subject }.to change { applicant.state }.from("applicant").to("attendee")
    end
  end

  describe "#make_application_reviewer" do
    let(:attendee) { create(:attendee) }

    subject { attendee.make_application_reviewer }

    it "should transition from key member to application reviewer" do
      expect { subject }.to change { attendee.state }.from("attendee").to("application_reviewer")
    end
  end
end
