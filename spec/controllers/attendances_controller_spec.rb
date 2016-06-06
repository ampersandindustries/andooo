require 'spec_helper'

describe AttendancesController do
  include AuthHelper

  before { Event.create(name: "cool_event") }

  let(:applicant) { create(:approved_application).user }

  context "logged in as an applicant" do
    before { login_as applicant }

    describe "GET new" do
      subject { get :new }

      it "renders the attendance page" do
        expect(subject).to render_template :new
      end

      context "with a user that already has an attendance" do
        before { create :attendance, user: applicant }

        it "redirects to the payment form" do
          expect(subject).to redirect_to payment_form_attendances_path
        end

        context "who is getting a scholarship ticket" do
          before { applicant.update(is_scholarship: true) }

          it "redirects to the scholarship form" do
            expect(subject).to redirect_to scholarship_form_attendances_path
          end
        end
      end

      context "with a user that's already confirmed their attendance" do
        before { applicant.make_attendee! }

        it "redirects to the details page" do
          expect(subject).to redirect_to details_attendances_path
        end
      end
    end

    describe "PUT create" do
      let(:attendance) { applicant.reload.attendances.first }

      subject { put :create, params }

      context "with good params" do
        let(:params) { { attendance: {
          badge_name: "my name",
          twitter_handle: "a_handle",
          dietary_restrictions: ["something"],
          gender: "my gender",
          roommate_request: "Duck McDuck",
          pronouns: "they/their",
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
          expect(attendance.roommate_request).to eq("Duck McDuck")
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
          expect(attendance.pronouns).to eq("they/their")
        end

        it "renders the payment form" do
          subject
          expect(response).to redirect_to payment_form_attendances_path
        end

        context "with a scholarship attendee" do
          before { applicant.update(is_scholarship: true) }

          it "renders the payment form" do
            subject
            expect(response).to redirect_to scholarship_form_attendances_path
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

      context "with bad params" do
        let(:params) { { attendance: { gender: "" } } }

        it "rerenders the form with errors" do
          expect(subject).to render_template :new
          expect(assigns[:attendance].errors.full_messages).to include("Gender can't be blank")
        end
      end
    end

    describe "GET edit" do
      before { create :attendance, user: applicant }

      let(:attendance) { applicant.reload.attendances.first }

      subject { get :edit }

      it "renders the attendance page" do
        expect(subject).to render_template :edit
      end

      it "assigns the correct attendance" do
        subject
        expect(assigns[:attendance]).to eq attendance
      end
    end

    describe "PUT update" do
      before { create :attendance, user: applicant }

      let(:attendance) { applicant.reload.attendances.first }

      subject { put :update, params }

      context "with good params" do
        let(:params) { { attendance: {
          badge_name: "Not a Lemur",
          twitter_handle: "several_tapirs",
          dietary_restrictions: ["something"],
          gender: "my gender",
          roommate_request: "Duck McDuck",
          pronouns: "they/their",
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
          expect(attendance.badge_name).to eq("Not a Lemur")
          expect(attendance.twitter_handle).to eq("several_tapirs")
        end

        it "doesn't create another attendance" do
          expect { subject }.not_to change { Attendance.count }
        end

        it "renders the details page" do
          subject
          expect(response).to redirect_to details_attendances_path
        end

        context "with a scholarship attendee" do
          before { applicant.update(is_scholarship: true) }

          it "renders the details page" do
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

      context "with bad params" do
        let(:params) { { attendance: { gender: "" } } }

        it "rerenders the form with errors" do
          expect(subject).to render_template :edit
          expect(assigns[:attendance].errors.full_messages).to include("Gender can't be blank")
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
          amount: "32500",
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
          expect(charge.amount).to eq 325_00
          expect(charge.status).to eq "succeeded"
        end

        it "redirects to the attendances page" do
          expect(subject).to redirect_to details_attendances_path
        end

        it "marks the applicant as an attendee" do
          expect { subject }.to change { applicant.state }.from("applicant").to("attendee")
        end
      end

      context "when something goes wrong with Stripe" do
        before { StripeMock.prepare_card_error(:card_declined) }

        it "adds an error to the flash and renders the edit page" do
          subject
          expect(flash[:error]).to eq "The card was declined"
          expect(response).to render_template :payment_form
        end

        it "does not mark the applicant as an attendee" do
          expect { subject }.not_to change { applicant.state }.from("applicant")
        end
      end
    end

    describe "GET scholarship_form" do
      subject { get :scholarship_form }

      it "renders the attendance page" do
        expect(subject).to render_template :scholarship_form
      end
    end

    describe "PUT confirm_scholarship" do
      subject { put :confirm_scholarship, params }

      context "with the agreements checked" do
        let(:params) { { attending: "yes" } }

        it "marks the applicant as an attendee" do
          expect { subject }.to change { applicant.state }.from("applicant").to("attendee")
        end

        it "redirects to the attendances page" do
          expect(subject).to redirect_to details_attendances_path
        end
      end

      context "with the agreement not checked" do
        let(:params) { { } }

        it "rerenders the form" do
          expect(subject).to render_template :scholarship_form
        end
      end

      context "with someone who has already confirmed" do
        let(:params) { { attending: "yes" } }

        before { applicant.make_attendee! }

        it "doesn't call make_attendee!" do
          expect(applicant).not_to receive(:make_attendee!)
          subject
        end

        it "redirects to the attendances page" do
          expect(subject).to redirect_to details_attendances_path
        end
      end
    end

    describe "PUT decline" do
      subject { put :decline }

      context "with an accepted application" do
        it "marks the application as declined" do
          expect { subject }.to change { applicant.reload.application.state }.from("approved").to("declined")
        end

        it "set a message and redirects to the root path" do
          expect(subject).to redirect_to root_path
          expect(flash[:message]).to eq "Bummer! Thanks for letting us know you can't attend."
        end

        it "sends an email" do
          expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
        end
      end

      context "with an application already declined" do
        before do
          applicant.application.decline!
        end

        it "redirects to root" do
          expect(subject).to redirect_to root_path
        end
      end
    end
  end
end
