require "spec_helper"

describe "confirming attendance and paying money to attend AndConf" do
  let(:applicant) { create(:approved_application).user }

  before do
    page.set_rack_session(user_id: applicant.id)
  end

  it "allows applicants to give us their precious deets" do
    visit new_attendances_path

    fill_in "attendance_gender", with: "NB"
    save_and_open_page
    click_on "Submit"

    expect(page).to have_content "Tickets to AndConf cost $300"
  end

  it "allows applicants to pay for their ticket" do
    save_and_open_page
    click "Pay"

  end

end

describe "confirming scholarship attendance" do

end
