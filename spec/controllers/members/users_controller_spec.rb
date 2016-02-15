require 'spec_helper'

describe Members::UsersController do
  include AuthHelper

  let(:someone_cool) { create(:member) }

  describe 'GET index' do
    subject { get :index }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe 'GET show' do
    subject { get :show, id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe 'GET setup' do
    subject { get :setup, user_id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe 'PATCH finalize' do
    subject {  patch :finalize, user_id: someone_cool.id, user: {dues_pledge: 25} }

    it_should_behave_like "deny non-members", [:visitor, :applicant]

    it 'updates Google email and dues pledge if logged in' do
      user = login_as(:member, name: 'Foo Bar', email: 'someone@foo.bar')

      patch :finalize, user_id: user.id, user: {
        dues_pledge: 25,
        email_for_google: 'googly-eyes@example.com'
      }

      expect(response).to render_template "setup"

      expect(user.dues_pledge).to eq(25)
      expect(user.email_for_google).to eq('googly-eyes@example.com')
    end
  end
end
