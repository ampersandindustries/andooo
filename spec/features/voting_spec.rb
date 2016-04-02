require "spec_helper"

describe "voting on an application" do
  let(:application) { create(:application) }

  before do
    page.set_rack_session(user_id: member.id)
  end

  context "when logged in as a voting member" do
    let(:member) { create(:voting_member) }

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

  context "logged in as a non-voting member" do
    let(:member) { create(:member) }

    it "does not allow the member to vote" do
      visit volunteers_application_path(application)
      expect(page).to have_content "Only Voting Members Can Vote"
      expect(page).not_to have_button "No"
      expect(page).not_to have_button "Yes"
    end
  end
end
