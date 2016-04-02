require "spec_helper"

describe Volunteers::DuesController do
  include AuthHelper

  let(:member) { create(:member) }

  describe "GET show" do
    subject { get :show, user_id: member.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it "redirects if not logged in" do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe "POST update" do
    before do
      StripeMock.start
      # TODO: remove api_key setting when this issue is fixed:
      # https://github.com/rebelidealist/stripe-ruby-mock/issues/209
      Stripe.api_key = "coolapikey"
      Stripe::Plan.create(:id => "test_plan",
        :amount => 5000,
        :currency => "usd",
        :interval => "month",
        :name => "test plan")

      # Must set referrer so that DuesController#redirect_target works
      request.env['HTTP_REFERER'] = 'http://example.com/members/users/x/dues'
    end

    after do
      StripeMock.stop
    end

    let(:token) { StripeMock.generate_card_token({}) }

    let(:params) do
      {
        user_id: user.id,
        email: "user@example.com",
        plan: "test_plan",
        token: token
      }
    end

    let!(:user) { login_as(:member, name: "Foo Bar", email: "someone@foo.bar") }

    subject(:post_dues) { post :update, params }

    context "when the user is coming from the account setup page" do
      # Must set referrer so that DuesController#redirect_target works
      before { request.env['HTTP_REFERER'] = 'http://example.com/members/users/x/setup' }

      it "redirects to the membership setup page" do
        expect(subject).to redirect_to volunteers_user_setup_path(user)
      end
    end

    context "when the user already has a Stripe ID" do
      let(:customer) do
        customer = Stripe::Customer.create({
            email: "user@example.com",
            source: StripeMock.generate_card_token({})
          })
      end

      before do
        user.update_column(:stripe_customer_id, customer.id)
      end

      context "previous subscription has been canceled" do
        it "creates new subscription with plan" do
          post_dues
          subscription = Stripe::Customer.retrieve(user.stripe_customer_id).subscriptions.first
          expect(subscription.plan.id).to eq("test_plan")
        end

        it "redirects to the manage dues page" do
          expect(subject).to redirect_to volunteers_user_dues_path(user)
        end
      end

      context "has a prior payment source" do
        before { customer = Stripe::Customer.retrieve(user.stripe_customer_id) }

        let!(:previous_default_source) { Stripe::Customer.retrieve(user.stripe_customer_id).sources.first }

        it "updates their card" do
          post_dues
          customer = Stripe::Customer.retrieve(user.stripe_customer_id)
          expect(customer.default_source).to_not eq(previous_default_source)
          subscription = customer.subscriptions.first
          expect(subscription.plan.id).to eq("test_plan")
        end
      end
    end

    context "when the user doesn't have a Stripe ID" do

      it "updates their stripe customer ID in the database" do
        post_dues
        expect(user.stripe_customer_id).to be_present
        subscription = Stripe::Customer.retrieve(user.stripe_customer_id).subscriptions.first
        expect(subscription.plan.id).to eq("test_plan")
      end
    end
  end
end
