# frozen_string_literal: true
require "rails_helper"

RSpec.describe "Candidate Onboarding Flow", type: :system do
  let(:candidate) { create(:user, email: "test@example.com", password: "password", role: :candidate) }
  let(:profile) { create(:candidate_profile, user: candidate) }

  before do
    driven_by(:rack_test)
    login_as candidate
  end

  describe "Step 1: CV Upload" do
    it "shows the upload page" do
      visit onboarding_upload_cv_path
      expect(page).to have_content("Upload your CV")
      expect(page).to have_button("Upload CV")
      expect(page).to have_button("Continue manually")
    end

    it "rejects invalid file type" do
      visit onboarding_upload_cv_path
      attach_file "file", Rails.root.join("spec/fixtures/test.txt"), make_visible: true
      click_button "Upload CV"
      expect(page).to have_content("Unsupported file type")
    end

    it "allows continuing manually" do
      visit onboarding_upload_cv_path
      click_button "Continue manually"
      expect(page).to have_current_path(onboarding_review_path)
    end
  end

  describe "Step 2: Profile Review" do
    before do
      profile
      visit onboarding_review_path
    end

    it "shows all form sections" do
      expect(page).to have_content("Review your profile")
      expect(page).to have_content("Personal Details")
      expect(page).to have_content("Job Preferences")
      expect(page).to have_content("Employment & Compensation")
      expect(page).to have_content("Education")
      expect(page).to have_content("Work Experience")
      expect(page).to have_content("Skills")
      expect(page).to have_content("Availability")
      expect(page).to have_content("Additional Information")
    end

    it "has pre-filled fields from the profile" do
      expect(find_field("candidate_profile_first_name").value).to eq("John")
      expect(find_field("candidate_profile_last_name").value).to eq("Doe")
      expect(find_field("candidate_profile_email").value).to eq("john@example.com")
    end

    it "validates required fields on save" do
      fill_in "candidate_profile_first_name", with: ""
      click_button "Save Profile"
      expect(page).to have_content("can't be blank")
    end
  end

  describe "Conditional field logic" do
    it "shows BIG registration for dentist role", js: true do
    end
  end
end
