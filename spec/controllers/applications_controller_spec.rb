require 'spec_helper'

describe ApplicationsController do
  include AuthHelper

  describe 'GET new' do
    it 'should redirect to root if not logged in' do
      get :new
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      login_as(:visitor)
      get :new
      expect(response).to redirect_to :root
    end

    it 'should redirect to edit if logged in as applicant' do
      user = login_as(:applicant)
      get :new
      expect(response).to redirect_to edit_application_path(user.application)
    end

    it 'should redirect to root if logged in as member' do
      login_as(:member)
      get :new
      expect(response).to redirect_to :root
    end
  end

  describe 'GET show' do
    it 'should redirect to root if not logged in' do
      get :show, id: 1
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      get :show, id: user.application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      get :show, id: user.application.id
      expect(response).to redirect_to :root
    end

    describe 'if logged in as applicant' do
      let(:user) { create :applicant }
      let(:other_user) { create :applicant }

      before { log_in(user) }

      it 'should render own application' do
        get :show, id: user.application.id
        expect(response).to render_template :show
      end

      it 'should not render application of another user' do
        get :show, id: other_user.application.id
        expect(response).to redirect_to :root
      end
    end
  end

  describe 'GET edit' do
    it 'should redirect to root if not logged in' do
      get :edit, id: User.make!(:applicant).application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      get :edit, id: user.application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      get :edit, id: user.application.id
      expect(response).to redirect_to :root
    end

    describe 'if logged in as applicant' do
      let(:user) { create :applicant }
      let(:other_user) { create :applicant }

      before { log_in(user) }

      it 'should render edit for own application' do
        get :edit, id: user.application.id
        expect(response).to render_template :edit
      end

      it "should redirect to root for another user's application" do
        get :edit, id: other_user.application.id
        expect(response).to redirect_to :root
      end
    end
  end

  describe 'POST update' do
    it 'should redirect to root if not logged in' do
      post :update, id: User.make!(:applicant).application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as visitor' do
      user = login_as(:visitor)
      post :update, id: user.application.id
      expect(response).to redirect_to :root
    end

    it 'should redirect to root if logged in as member' do
      user = login_as(:member)
      post :update, id: user.application.id
      expect(response).to redirect_to :root
    end

    describe 'if logged in as applicant' do
      let(:user) { login_as(:applicant) }
      let(:application) { user.application }
      let(:params) { {
        id: application.id,
        user: { application_attributes: application_params }
      } }

      subject { post :update, params }

      context "when saving an application" do
        let(:application_params) { { id: application.id, agreement_deadline: true } }

        before { params.merge! save: "unimportant string" }

        it "should update the user's application" do
          expect { subject }.to change { application.agreement_deadline }.from(false).to(true)
          expect(response).to redirect_to edit_application_path(application)
        end

        context "missing required fields" do
          before { params.merge!(user: { email: "" })}

          it "should not update the user" do
            expect { subject }.not_to change { user.reload.email }
          end

          it "should show an error message" do
            subject
            expect(flash[:error]).to include "Application not saved"
          end
        end
      end

      context "when submitting an application" do
        before { params.merge! submit: "unimportant string" }

        let(:application_params) do
          {
            id: application.id, agreement_coc: true, agreement_attendance: true, agreement_deadline: true,
            scholarship: "yes", travel_stipend: "maybe", attend_last_year: true, referral_code: "lemur_friend"
          }
        end

        context "with all required fields" do
          it "should add an notice to the flash" do
            subject
            expect(flash[:notice]).to include "Application submitted"
          end

          it "should submit the application" do
            expect { subject }.to change { application.state }.from("started").to("submitted")
            expect(application.travel_stipend).to eq "maybe"
            expect(application.referral_code).to eq "lemur_friend"
          end
        end

        context "missing required fields" do
          let(:application_params) { { id: application.id, agreement_deadline: true } }

          it "should add an error to the flash" do
            subject
            expect(flash[:error]).to include "Application not submitted"
          end

          it "should not submit the application" do
            expect { subject }.not_to change { application.state }.from("started")
          end
        end
      end
    end
  end
end
