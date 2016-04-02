require 'spec_helper'

describe Volunteers::VotesController do
  include AuthHelper

  let(:application) { create(:application) }

  describe "POST create" do
    let(:params) { { vote: { application_id: application.id }, "vote_no" => "No" } }

    subject { post :create, params }

    before do
      login_as(application_reviewer)
    end

    context "when logged in as a application reviewer" do
      let(:application_reviewer) { create(:application_reviewer) }

      it "create the correct vote" do
        subject
        expect(Vote.last.application_id).to eq application.id
        expect(Vote.last.user_id).to eq application_reviewer.id
      end

      describe "voting no" do
        it "stores the correct value" do
          subject
          expect(Vote.last.value).to be_falsey
        end
      end

      describe "voting yes" do
        let(:params) { {
          vote: { application_id: application.id }, "vote_yes" => "Yes"
        } }

        it "stores the correct value" do
          subject
          expect(Vote.last.value).to be_truthy
        end
      end
    end
  end

  describe "DELETE destroy" do
    subject { delete :destroy, params }

    before do
      login_as(application_reviewer)

      vote = Vote.new
      vote.application_id = application.id
      vote.user_id = application_reviewer.id
      vote.value = true
      vote.save
    end

    context "when logged in as a application reviewer" do
      let(:application_reviewer) { create(:application_reviewer) }
      let(:params) { { id: application.id } }
      let(:vote) { Vote.where(application_id: application.id,
                              user_id: application_reviewer.id,
                              value: true).first
      }

      it "allows me to remove my vote" do
        expect { subject }.to change { Vote.count }.by(-1)
        expect(vote).to be_nil
      end
    end
  end
end
