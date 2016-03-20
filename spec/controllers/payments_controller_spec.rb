require 'spec_helper'

describe PaymentsController do
  include AuthHelper

  let!(:user) { login_as(:member, name: "Hexipal", email: "hexipal@example.com") }

  describe "GET edit" do
    subject { get :edit }

    it "succeeds" do
      expect(subject).to render_template :edit
    end
  end

  describe "POST update" do
    let(:token) { StripeMock.generate_card_token({}) }
    let(:params) do
      {
        user_id: user.id,
        email: "user@example.com",
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

    subject { post :update, params }

    context "if the attendee doesn't have a stripe customer ID" do
      it "creates a stripe user" do
        expect { subject }.to change { user.stripe_customer_id }.from(nil)
      end

      it "charges them money" do
        subject
        charge = Stripe::Customer.retrieve(user.stripe_customer_id).charges.first
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
        expect(response).to render_template :edit
      end
    end
  end
end
