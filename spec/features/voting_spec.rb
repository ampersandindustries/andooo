require "spec_helper"

describe "voting on an application" do
  let(:application) { create(:application) }

  before do
    page.set_rack_session(user_id: application_reviewer.id)
  end

  context "when logged in as a application reviewer" do
    let(:application_reviewer) { create(:application_reviewer) }

    it "allows the member to vote yes" do
      visit volunteers_application_path(application)
      expect(page).to have_content "Votes for membership (0)"
      click_button "Yes"
      expect(page).to have_content "Votes for membership (1)"
      expect(page).to have_content "You voted yes"
    end

    it "allows the member to vote no" do
      visit volunteers_application_path(application)
      expect(page).to have_content "Votes against membership (0)"
      click_button "No"
      expect(page).to have_content "Votes against membership (1)"
      expect(page).to have_content "You voted no"
    end

    it "allows the member to remove their vote" do
      visit volunteers_application_path(application)
      click_button "No"
      expect(page).to have_content "Votes against membership (1)"
      click_link "Remove your vote"
      expect(page).to have_content "Votes against membership (0)"
    end
  end
end
