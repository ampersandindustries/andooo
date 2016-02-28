require "spec_helper"

describe "confirming attendance at AndConf" do
  let(:applicant) { create(:approved_application).user }

  before do
    page.set_rack_session(user_id: applicant.id)
  end

  it "allows applicants to confirm they're coming" do
    visit edit_attendances_path

    fill_in "Gender", with: "NB"
    click_on "Submit"

    expect(page).to have_content "AndConf is going to be great!"
  end
end
