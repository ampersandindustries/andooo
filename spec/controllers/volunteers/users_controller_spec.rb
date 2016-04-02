require 'spec_helper'

describe Volunteers::UsersController do
  include AuthHelper

  let(:someone_cool) { create(:application_reviewer) }

  describe 'GET index' do
    subject { get :index }

    it_should_behave_like "deny non-application reviewers", [:visitor, :applicant, :attendee]
    it_should_behave_like "allow application reviewers", [:application_reviewer]

    it 'redirects if not logged in' do
      subject
      expect(response).to redirect_to :root
    end
  end

  describe 'GET show' do
    subject { get :show, id: someone_cool.id }

    it_should_behave_like "deny non-application reviewers", [:visitor, :applicant, :attendee]
    it_should_behave_like "allow application reviewers", [:application_reviewer]

    it 'redirects if not logged in' do
      subject
      expect(response).to redirect_to :root
    end
  end
end
