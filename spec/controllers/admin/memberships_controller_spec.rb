require "spec_helper"

describe Admin::MembershipsController do
  include AuthHelper

  describe "GET index" do
    context "when logged in as an admin" do
      before { login_as(:application_reviewer, is_admin: true) }

      context "as HTML" do
        it "allows admin to view admin members index" do
          get :index, format: "html"
          expect(response).to render_template :index
        end
      end

      context "as JSON" do
        let!(:attendee) { create(:attendee, name: "Several Lemurs", email: "cats@example.com") }

        it "allows admin to view attendees as json" do
          get :index, format: "json"
          expect(response.body).to include "Several Lemurs"
        end
      end
    end

    context "logged in as a non-admin" do
      before { login_as(:attendee) }

      context "as HTML" do
        it "should redirect to root if logged in as an attendee" do
          get :index, format: "html"
          expect(response).to redirect_to :root
        end
      end

      context "as JSON" do
        it "should redirect to root if logged in an attendee" do
          get :index, format: "json"
          expect(response).to redirect_to :root
        end
      end
    end
  end

  describe "PUT update" do
    subject { put :update, params }

    before { login_as(:application_reviewer, is_admin: true) }

    context "marking an attendee as on scholarship" do
      let(:attendee) { create :attendee }
      let(:params) { { id: attendee.id, user: { is_scholarship: true } } }

      it "should mark scholarship as true" do
        expect { subject }.to change { attendee.reload.is_scholarship }.from(false).to(true)
      end
    end
  end
end
