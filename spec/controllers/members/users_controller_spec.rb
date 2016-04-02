require 'spec_helper'

describe Volunteers::UsersController do
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
end
