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

  it 'should transition from visitor to applicant' do
    user = User.new
    user.username = 'sallyride'
    user.email = 'cat@example.org'
    user.save!

    expect(user.state).to eq('visitor')
    user.make_applicant!
    expect(user.state).to eq('applicant')
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
