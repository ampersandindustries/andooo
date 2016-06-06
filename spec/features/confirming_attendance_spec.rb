require "spec_helper"

describe "confirming attendance to attend AndConf" do
  let(:applicant) { create(:approved_application).user }

  before do
    page.set_rack_session(user_id: applicant.id)
    Event.create(name: "cool_event")
  end

  it "allows paying attendees to give us their precious deets" do
    visit new_attendances_path

    fill_in_the_deets

    click_on "Continue to buy your ticket"

    expect(page).to have_content "Tickets to AndConf cost $325"

    # TODO maybe write an integration spec for stripe stuff??
  end

  describe "confirming scholarship attendance" do
    before { applicant.update(is_scholarship: true) }

    it "allows applicants to give us their precious deets" do
      visit new_attendances_path

      fill_in_the_deets

      click_on "Continue to confirm scholarship"

      expect(page).to have_content "Scholarship Confirmation"
      check "I can definitely attend the entirety of the conference."
      click_on "Confirm Attendance"

      expect(page).to have_content "AndConf is going to be great!"

      expect(applicant.reload.state).to eq "attendee"
    end
  end

  describe "updating attendance details" do
    before do
      create :attendance, user: applicant
      applicant.make_attendee!
    end

    it "allows confirmed folks to fill out the details" do
      visit edit_attendances_path

      fill_in_the_deets
      click_on "Update"

      expect(page).to have_content "AndConf is going to be great!"
    end
  end

  describe "declining attendance" do
    it "allows people to decline attending AndConf" do
      visit new_attendances_path

      click_on "I can't attend"

      expect(page).to have_content "Bummer! Thanks for letting us know"
      expect(applicant.reload.application.state).to eq "declined"
    end
  end
end

def fill_in_the_deets
  fill_in "Badge Name", with: "Cool Attendee"
  fill_in "Gender", with: "NB"
  fill_in "Roommate Request", with: "Fuzzy Lemur Jr."
  fill_in "Pronouns", with: "they/their"
  check "attendance_dietary_restrictions_vegan"
  fill_in "Additional dietary restrictions or concerns (e.g. needing access to a fridge to store medication)", with: "Need access to a kitchen"
  fill_in "Twitter Handle", with: "@fun_times"
  select "I have no preference", from: "Sleeping Preferences"
  select "Maybe", from: "Are you staying at St. Dorothy's Rest on Sunday night?"
  select "No", from: "Are you flying into the Bay Area for AndConf?"
  select "I will be taking the free shuttle leaving downtown San Francisco on FRIDAY, August 12th at 3pm", from: "Transportation to St. Dorothy's Rest"
  select "I will be driving myself or organizing carpooling via the doc or #transportation slack channel", from: "Transportation from St. Dorothy's Rest"
  check "I have read and agree to adhere to AndConf's"
  check "The trails around St. Dorothy's Rest are unmaintained and the pool at St. Dorothy's Rest is unsupervised. I acknowledge that if choose to use the pool or trails at any point, any use will be at my own risk."
  check "I plan to attend the entire conference (Friday evening through Sunday evening)"
  check "Sure, I'd like to help during AndConf."
end
