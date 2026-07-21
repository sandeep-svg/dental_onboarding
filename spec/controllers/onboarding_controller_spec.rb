# frozen_string_literal: true
require "rails_helper"

RSpec.describe OnboardingController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET #upload_cv" do
    it "returns http success" do
      get :upload_cv
      expect(response).to have_http_status(:success)
    end

    it "builds a new candidate profile if none exists" do
      get :upload_cv
      expect(assigns(:profile)).to be_a(CandidateProfile)
      expect(assigns(:profile)).not_to be_persisted
    end
  end

  describe "POST #process_cv" do
    context "with no file" do
      it "shows an error" do
        post :process_cv
        expect(flash[:alert]).to eq("Please select a file to upload")
      end
    end

    context "with invalid file type" do
      it "rejects the file" do
        file = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/test.txt"), "text/plain")
        post :process_cv, params: { file: file }
        expect(flash[:alert]).to include("Unsupported file type")
      end
    end
  end

  describe "GET #review" do
    context "without a profile" do
      it "redirects to upload" do
        get :review
        expect(response).to redirect_to(onboarding_upload_cv_path)
      end
    end

    context "with continue_manual" do
      it "creates a profile and redirects to review" do
        post :continue_manual
        expect(response).to redirect_to(onboarding_review_path)
        expect(controller.current_user.candidate_profile).to be_persisted
      end
    end

    context "with a profile" do
      let!(:profile) { create(:candidate_profile, user: user) }

      it "returns http success" do
        get :review
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH #save_profile" do
    let!(:profile) { create(:candidate_profile, user: user) }

    context "with valid params" do
      it "updates the profile" do
        patch :save_profile, params: {
          candidate_profile: {
            first_name: "Jane",
            consent_accepted: "1",
            preferred_regions: ["Amsterdam"],
            desired_employment_type: ["employed"],
            available_working_days: ["monday"],
            max_travel_time: 30,
            years_of_experience: 5,
            available_from: Date.tomorrow,
            country: "Netherlands",
            search_status: "active"
          }
        }
        expect(profile.reload.first_name).to eq("Jane")
      end

      it "marks onboarding as completed" do
        patch :save_profile, params: {
          candidate_profile: {
            first_name: "Jane",
            consent_accepted: "1",
            preferred_regions: ["Amsterdam"],
            desired_employment_type: ["employed"],
            available_working_days: ["monday"],
            max_travel_time: 30,
            years_of_experience: 5,
            available_from: Date.tomorrow,
            country: "Netherlands",
            search_status: "active"
          }
        }
        expect(profile.reload.onboarding_completed).to be true
      end
    end

    context "with invalid params" do
      it "renders review with errors" do
        patch :save_profile, params: {
          candidate_profile: {
            first_name: "",
            consent_accepted: "0"
          }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
