require 'spec_helper'

describe AttendancesController do
  include AuthHelper

  let(:applicant) { create(:approved_application).user }

  context "logged in as an applicant" do
    before { login_as applicant }

    describe "GET edit" do
      subject { get :edit }

      it "renders the attendance page" do
        expect(subject).to render_template :edit
      end
    end

    describe "PUT confirm" do
      subject { put :confirm, params }

      context "with good params" do
        let(:params) { { gender: "nb" } }

        it "confirms the attedance of the current logged-in applicant" do
          expect { subject }.to change { applicant.state }.from("applicant").to("attendee")
        end

        it "updates the user" do
          expect { subject }.to change { applicant.reload.gender }.from(nil).to("nb")
        end

        it "renders the show page" do
          subject
          expect(response).to redirect_to details_attendances_path
        end

        context "when the user is already confirmed" do
          before { applicant.make_attendee }

          it "doesn't try to transition the state again" do
            subject
            expect(response).to redirect_to details_attendances_path
          end
        end

        context "when the application was rejected" do
          let(:applicant) { create(:application).user }

          before { applicant.application.reject! }

          it "redirects to the root path" do
            subject
            expect(response).to redirect_to root_path
          end
        end
      end
    end
  end
end

