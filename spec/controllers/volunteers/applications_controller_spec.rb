require 'spec_helper'

describe Volunteers::ApplicationsController do
  include AuthHelper

  render_views

  before :each do
    @applicant = User.make!(:applicant)
  end

  describe 'GET show' do
    it 'redirects if not logged in' do
      get :show, id: @applicant.application.id
      expect(response).to redirect_to :root
    end

    it 'redirects if logged in as visitor' do
      login_as(:visitor)
      get :show, id: @applicant.application.id
      expect(response).to redirect_to :root
    end

    it 'redirects if logged in as applicant' do
      login_as(@applicant)
      get :show, id: @applicant.application.id
      expect(response).to redirect_to :root
    end

    it 'redirects if logged in as attendee' do
      attendee = create(:attendee)
      login_as(attendee)
      get :show, id: attendee.application.id
      expect(response).to redirect_to :root
    end

    describe 'for authenticated volunteer' do
      it 'redirects if application is in started state' do
        login_as(:application_reviewer)
        get :show, id: @applicant.application.id
        expect(flash[:error]).to match /not currently visible/
        expect(response).to redirect_to volunteers_root_path
      end

      it 'renders if application is in submitted state' do
        login_as(:application_reviewer)

        applicant = User.make!(:applicant)
        application = applicant.application
        application.update_attribute(:state, 'submitted')

        get :show, id: application.id
        expect(response).to render_template :show
      end

      it 'redirects if application is in approved state' do
        login_as(:application_reviewer)

        applicant = User.make!(:applicant)
        application = applicant.application
        application.update_attribute(:state, 'approved')

        get :show, id: application.id
        expect(response).to redirect_to volunteers_root_path
      end

      it 'redirects if application is in rejected state' do
        login_as(:application_reviewer)

        applicant = User.make!(:applicant)
        application = applicant.application
        application.update_attribute(:state, 'rejected')

        get :show, id: application.id
        expect(response).to redirect_to volunteers_root_path
      end
    end

    describe 'for submitted application' do
      before :each do
        @submitted_application = User.make!(:applicant).application
        @submitted_application.update_attribute(:state, 'submitted')
      end

      it 'renders voting form for application reviewer' do
        login_as(:application_reviewer)
        get :show, id: @submitted_application.id
        expect(response).to render_template :show
        expect(response.body).to have_selector(:css, "form#new_vote")
      end
    end
  end
end
