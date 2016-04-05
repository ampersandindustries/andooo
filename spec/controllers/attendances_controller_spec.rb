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
        let(:params) { { attendance: { 
                          badge_name: "my name",
                          twitter_handle: "a_handle",
                          dietary_restrictions: ["something"],
                          gender: "my gender",
                          sleeping_preference: "I have no preference",
                          staying_sunday_night: "yes",
                          flying_in: "no",
                          transport_to_venue: "I will be taking the free shuttle leaving downtown San Francisco on FRIDAY, August 12th at 3pm",
                          transport_from_venue: "I will be driving myself or organizing carpooling via the doc or #transportation slack channel",
                          agree_to_coc: true,
                          accept_trails_and_pool_risk: true,
                          attend_entire_conference: true,
                          interested_in_volunteering: true
                        } } }

        it "updates the attendance" do
          subject
          attendance.reload
          expect(attendance.badge_name).to eq("my name")
          expect(attendance.dietary_restrictions).to eq("[\"something\"]")
          expect(attendance.gender).to eq("my gender")
          expect(attendance.twitter_handle).to eq("a_handle")
          expect(attendance.sleeping_preference).to eq("I have no preference")
          expect(attendance.staying_sunday_night).to eq("yes")
          expect(attendance.flying_in).to eq("no")
          expect(attendance.agree_to_coc).to eq(true)
          expect(attendance.accept_trails_and_pool_risk).to eq(true)
          expect(attendance.attend_entire_conference).to eq(true)
          expect(attendance.interested_in_volunteering).to eq(true)
          expect(attendance.transport_to_venue).to eq("I will be taking the free shuttle leaving downtown San Francisco on FRIDAY, August 12th at 3pm")
          expect(attendance.transport_from_venue).to eq("I will be driving myself or organizing carpooling via the doc or #transportation slack channel")
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

