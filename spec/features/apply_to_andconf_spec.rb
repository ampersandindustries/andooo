require 'spec_helper'

describe "applying to andconf" do
  let(:camper) { create(:user) }
  let(:application_state) { camper.application.state }

  before do
    camper.update_attribute(:state, "applicant")
    page.set_rack_session(user_id: camper.id)
  end

  it "allows the user to submit an application" do
    visit edit_application_path(camper.application)

    fill_in_all_the_fields

    expect {
      click_on "Submit application"
    }.to change { camper.application.reload.state }.from("started").to("submitted")

    expect(page).to have_content "Application submitted!"
    expect(find_field("Why do you want to attend to AndConf?").value).to eq "I love lemurs!"
  end

  it "allows the user to save her application without submitting it" do
    visit edit_application_path(camper.application)
    expect(page).to have_content "If this application looks blanker than you left it"

    fill_in "Full name", with: "Beep Booper"

    first(:button, "Save without submitting").click

    expect(camper.application.state).to eq("started")
    expect(page).to have_content "Application draft saved!"
    expect {Application.count}.to change{Application.count}.by(0)
  end

  it "allows the user to update her application" do
    visit edit_application_path(camper.application)
    expect(page).to have_content "If this application looks blanker than you left it"

    fill_in_all_the_fields

    click_on "Submit application"

    fill_in "Full name", with: "Bop Beeper"

    first(:button, "Update application").click

    expect(find_field("Full name").value).to eq "Bop Beeper"
  end
end

private

def fill_in_all_the_fields
  fill_in "Full name", with: "Beep Booper"
  fill_in "Referral code", with: "friend_of_lemurs"
  fill_in "Why do you want to attend to AndConf?", with: "I love lemurs!"
  fill_in "What is your level of familiarity with intersectional feminism?", with: "The lemurs I hang out read a lot of bell hooks."
  fill_in "Is there an aspect of your background or identity that", with: "No, I am a lemur"
  choose "2 - 5 years"
  choose "Yes, I can only attend if I get a scholarship ticket"
  choose "No, my travel will be paid by my employer, myself, or other source."
  choose "No"

  check "I have read and agree to adhere to AndConf's Code of Conduct"
  check "If accepted, I will attend the entire conference, from the evening of Friday 8/12/15 through Sunday evening, 8/14/15."
  check "I agree to confirm or decline my attendance within 10 days if I am accepted."
end
