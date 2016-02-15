require 'spec_helper'

describe "applying to double union" do
  let(:cool_lady) { create(:user) }
  let(:application_state) { cool_lady.application.state }

  before do
    cool_lady.update_attribute(:state, "applicant")
    page.set_rack_session(user_id: cool_lady.id)
  end

  it "allows the user to submit an application" do
    visit new_application_path

    fill_in "Full name", with: "Beep Booper"
    check "user_application_attributes_agreement_terms"
    check "user_application_attributes_agreement_policies"
    check "user_application_attributes_agreement_female"

    expect {
      click_on "Submit application"
    }.to change { cool_lady.application.reload.state }.from("started").to("submitted")

    expect(page).to have_content "Application submitted!"
    expect(find_field('Full name').value).to eq "Beep Booper"
  end

  it "allows the user to save her application without submitting it" do
    visit new_application_path
    expect(page).to have_content "If this application looks blanker than you left it"

    fill_in "Full name", with: "Beep Booper"

    first(:button, "Save without submitting").click

    expect(cool_lady.application.state).to eq("started")
    expect(page).to have_content "Application saved"
    expect {Application.count}.to change{Application.count}.by(0)
  end

  it "allows the user to update her application" do
    visit new_application_path
    expect(page).to have_content "If this application looks blanker than you left it"

    fill_in "Full name", with: "Beep Booper"
    check "user_application_attributes_agreement_terms"
    check "user_application_attributes_agreement_policies"
    check "user_application_attributes_agreement_female"

    click_on "Submit application"

    fill_in "Full name", with: "Bop Beeper"

    first(:button, "Update application").click

    expect(find_field("Full name").value).to eq "Bop Beeper"
  end
end
