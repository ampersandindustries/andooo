require 'spec_helper'

describe AttendancesController do
  include AuthHelper

  let(:applicant) { create(:approved_application).user }

  context "logged in as an applicant" do
    before { login_as applicant }

    describe "GET new" do
      subject { get :new }

      it "renders the attendance page" do
        expect(subject).to render_template :new
      end
    end

    describe "PUT create" do
      let(:attendance) { applicant.attendances.first }

      subject { put :create, params }

      context "with good params" do
        let(:params) { { attendance: { gender: "nb" } } }

        it "updates the attendance" do
          subject
          expect(attendance.reload.gender).to eq "nb"
        end

        it "renders the payment form" do
          subject
          expect(response).to redirect_to payment_form_attendances_path
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

      context "with bad params" do
        let(:params) { { attendance: { gender: "" } } }

        it "rerenders the form with errors" do
          expect(subject).to render_template :new
          expect(attendance.errors.full_messages).to include("Gender can't be blank")
        end
      end
    end

    describe "GET payment_form" do
      subject { get :payment_form }

      it "renders the attendance page" do
        expect(subject).to render_template :payment_form
      end
    end

    describe "PUT pay" do
      let(:token) { StripeMock.generate_card_token({}) }
      let(:params) do
        {
          user_id: applicant.id,
          email: "applicant@example.com",
          amount: "30000",
          token: token
        }
      end

      before do
        StripeMock.start
        Stripe.api_key = "coolapikey"
      end

      after do
        StripeMock.stop
      end

      subject { put :pay, params }

      context "if the attendee doesn't have a stripe customer ID" do
        it "creates a stripe user" do
          expect { subject }.to change { applicant.stripe_customer_id }.from(nil)
        end

        it "charges them money" do
          subject
          charge = Stripe::Customer.retrieve(applicant.stripe_customer_id).charges.first
          expect(charge.amount).to eq 30000
          expect(charge.status).to eq "succeeded"
        end

        it "redirects to the attendances page" do
          expect(subject).to redirect_to details_attendances_path
        end
      end

      context "when something goes wrong with Stripe" do
        before { StripeMock.prepare_card_error(:card_declined) }

        it "adds an error to the flash and renders the edit page" do
          subject
          expect(flash[:error]).to eq "The card was declined"
          expect(response).to render_template :payment_form
        end
      end
    end
  end
end

