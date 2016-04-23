require 'spec_helper'

describe ApplicationForm do
  let(:application) { create(:unsubmitted_application) }
  let(:user) { application.user }
  let(:form) { ApplicationForm.new(user) }

  describe "#initialize" do
    subject { ApplicationForm.new(user) }

    it "set the user and application" do
      expect(subject.user).to eq user
      expect(subject.application).to eq application
    end
  end

  describe "#save_draft" do
    let(:params) { { name: "Basil Cat", email: "basil@example.com", diversity: "nope" } }

    subject { form.save_draft(params) }

    it "saves any changes to the application or user" do
      expect { subject }.to change { user.reload.name }.to "Basil Cat"
      expect(user.email).to eq "basil@example.com"
      expect(application.reload.diversity).to eq "nope"
    end

    context "missing name and email" do
      let(:params) { { name: "", email: "basil@example.com", diversity: "nope" } }

      it "doesn't update the user or the application" do
        expect { subject }.not_to change { user.reload.name }
        expect(user.application.reload.diversity).to eq nil
      end

      it "adds an error to the form" do
        subject
        expect(form.errors.full_messages).to eq ["Name can't be blank"]
      end
    end

    context "with an email address that's already been taken" do
      before { create :user, email: "basil@example.com" }

      it "doesn't update the user or the application" do
        expect { subject }.not_to change { user.reload.name }
        expect(user.application.reload.diversity).to eq nil
      end

      it "adds an error to the form" do
        subject
        expect(form.errors.full_messages.first).to include "Email has been taken."
      end
    end
  end

  describe "#submit" do
    let(:params) { {
      name: "Basil Cat", email: "basil@example.com", agreement_coc: "1", agreement_attendance: "1",
      agreement_deadline: "1", why_andconf: "I love trees", feminism: "I am feminist",
      programming_experience: "1 - 2 years", scholarship: "no", travel_stipend: "no", attend_last_year: "true"
    } }

    subject { form.submit(params) }

    context "with all required fields" do
      it "saves any changes to the application or user" do
        expect { subject }.to change { user.reload.name }.to "Basil Cat"
        expect(user.email).to eq "basil@example.com"
        expect(application.reload.why_andconf).to eq "I love trees"
      end

      it "marks the application as submitted" do
        expect { subject }.to change { application.reload.state }.from("started").to("submitted")
      end
    end

    context "missing required fields" do
      let(:params) { { name: "Basil Cat", email: "basil@example.com", diversity: "nope" } }

      it "doesn't make any changes" do
        expect { subject }.not_to change { user.reload.name }
        expect(application.reload.why_andconf).to eq nil
        expect(application.state).to eq ("started")
      end

      it "sets some good errors on the form" do
        subject
        expect(form.errors.full_messages).to include("Answer to 'What is your level of familiarity with intersectional feminism?' can't be blank")
      end
    end

    context "with a model validation" do
      before { create :user, email: "basil@example.com" }

      it "doesn't make any changes" do
        expect { subject }.not_to change { user.reload.name }
        expect(application.reload.why_andconf).to eq nil
        expect(application.state).to eq ("started")
      end
    end
  end

  describe "#flash_message" do
    subject { form.flash_message }

    context "saving a draft" do
      before { form.save_draft(params) }

      context "saving a draft successfully" do
        let(:params) { { name: "Basil Cat", email: "basil@example.com", diversity: "nope" } }

        it "returns the correct string" do
          expect(subject).to eq "Application draft saved!"
        end
      end

      context "saving a draft with errors" do
        let(:params) { { name: "", email: "basil@example.com", diversity: "nope" } }

        it "returns the correct string" do
          expect(subject).to eq "Whoops! Name can't be blank"
        end
      end
    end

    context "submitting an application" do
      before { form.submit(params) }

      context "submitting successfully" do
        let(:params) { {
          name: "Basil Cat", email: "basil@example.com", agreement_coc: "1", agreement_attendance: "1",
          agreement_deadline: "1", why_andconf: "I love trees", feminism: "I am feminist",
          programming_experience: "1 - 2 years", scholarship: "no", travel_stipend: "no", attend_last_year: "true"
        } }

        it "returns the correct string" do
          expect(subject).to eq "Application submitted!"
        end
      end

      context "submitting with errors" do
        context "when required fields are missing" do
          let(:params) { { name: "Basil Cat", email: "basil@example.com", diversity: "nope" } }

          it "returns the correct string" do
            expect(subject).to include("Answer to 'What is your level of familiarity with intersectional feminism?' can't be blank")
          end
        end

        context "when fields are too long" do
          let(:too_long_answer) { ("a" * 4001) }
          let(:params) { { name: "Basil Cat", email: "basil@example.com", diversity: too_long_answer } }

          it "returns the correct string" do
            expect(subject).to include "Answer to 'Is there an aspect of your background or identity that you think would make AndConf more diverse?' must be 1,000 characters or less"
          end
        end
      end
    end
  end
end
