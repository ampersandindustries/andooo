require 'spec_helper'

describe "applying to andconf" do
  let(:camper) { create(:user) }
  let(:application_state) { camper.application.state }

  before do
    camper.update_attribute(:state, "applicant")
    page.set_rack_session(user_id: camper.id)
  end

  it "allows the user to submit an application" do
    visit new_application_path

    fill_in "Full name", with: "Beep Booper"
    fill_in "Why do you want to attend to AndConf?", with: "I love lemurs!"
    fill_in "What is your level of familiarity with intersectional feminism?", with: "The lemurs I hang out read a lot of bell hooks."
    fill_in "Is there an aspect of your background or identity that", with: "No, I am a lemur"
    choose "2 - 5 years"
    choose "Yes, I can only attend if I get a scholarship ticket"
    choose "No, my travel will be paid by my employer, myself, or other source."

    check "user_application_attributes_agreement_coc"
    check "user_application_attributes_agreement_attendance"
    check "user_application_attributes_agreement_deadline"

    expect {
      click_on "Submit application"
    }.to change { camper.application.reload.state }.from("started").to("submitted")

    expect(page).to have_content "Application submitted!"
    expect(find_field("Why do you want to attend to AndConf?").value).to eq "I love lemurs!"
  end

  it "allows the user to save her application without submitting it" do
    visit new_application_path
    expect(page).to have_content "If this application looks blanker than you left it"

    fill_in "Full name", with: "Beep Booper"

    first(:button, "Save without submitting").click

    expect(camper.application.state).to eq("started")
    expect(page).to have_content "Application saved"
    expect {Application.count}.to change{Application.count}.by(0)
  end

  it "allows the user to update her application" do
    visit new_application_path
    expect(page).to have_content "If this application looks blanker than you left it"

    fill_in "Full name", with: "Beep Booper"
    check "user_application_attributes_agreement_coc"
    check "user_application_attributes_agreement_attendance"
    check "user_application_attributes_agreement_deadline"

    click_on "Submit application"

    fill_in "Full name", with: "Bop Beeper"

    first(:button, "Update application").click

    expect(find_field("Full name").value).to eq "Bop Beeper"
  end
end
