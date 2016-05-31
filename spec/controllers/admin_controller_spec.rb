require 'spec_helper'

describe AdminController do
  include AuthHelper

  describe 'as an admin user' do
    let(:an_application) { create(:application) }

    describe 'GET applications' do
      subject { get :applications, format: "html" }

      context "as HTML" do
        it 'allows user to view admin applications index' do
          login_as(:application_reviewer, is_admin: true)
          subject
          expect(response).to render_template :applications
        end

        describe 'as a non-admin user' do
          it 'should redirect to root if logged in as member' do
            login_as(:attendee)
            subject
            expect(response).to redirect_to :root
          end
        end
      end

      context "as CSV" do
        subject { get :applications, format: "csv" }

        it 'allows user to see a CSV of applications' do
          login_as(:application_reviewer, is_admin: true)
          subject
          expect(response).to be_success
        end

        describe 'as a non-admin user' do
          it 'should redirect to root if logged in as member' do
            login_as(:attendee)
            subject
            expect(response).to redirect_to :root
          end
        end
      end
    end

    describe 'PATCH approve' do
      describe 'with good params' do
        let(:application_params) { { application: { id: an_application.id } } }

        it 'should approve the relevant application' do
          login_as(:application_reviewer, is_admin: true)
          expect do
            patch :approve, application_params
          end.to change { an_application.reload.state }.from("submitted").to("approved")
        end
      end
    end

    describe 'PATCH reject' do
      let(:application_params) { { application: { id: an_application.id } } }

      it 'should reject the relevant application' do
        login_as(:application_reviewer, is_admin: true)
        expect do
          patch :reject, application_params
        end.to change { an_application.reload.state }.from("submitted").to("rejected")
      end
    end

    describe 'POST add_membership_note' do
      let!(:attendee) { create(:attendee) }
      let(:params) { { user: { id: attendee.id, membership_note: "beeeep" }, format: :json } }

      it 'allows the admin to make notes on the new user' do
        login_as(:application_reviewer, is_admin: true)
        expect do
          post :save_membership_note, params
        end.to change { attendee.reload.membership_note }.from(nil).to("beeeep")
      end
    end
  end
end
