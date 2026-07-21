# frozen_string_literal: true
require "rails_helper"

RSpec.describe CandidateProfile, type: :model do
  subject(:profile) { build(:candidate_profile) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:candidate_documents).dependent(:destroy) }
    it { is_expected.to have_many(:educations).dependent(:destroy) }
    it { is_expected.to have_many(:work_experiences).dependent(:destroy) }
    it { is_expected.to have_many(:candidate_skills).dependent(:destroy) }
    it { is_expected.to have_many(:skills).through(:candidate_skills) }
    it { is_expected.to have_many(:candidate_languages).dependent(:destroy) }
    it { is_expected.to have_many(:languages).through(:candidate_languages) }
  end

  describe "validations" do
    it "validates required fields on final_save" do
      profile.first_name = nil
      profile.last_name = nil
      profile.email = nil
      profile.valid?(:final_save)
      expect(profile.errors[:first_name]).to include("can't be blank")
      expect(profile.errors[:last_name]).to include("can't be blank")
      expect(profile.errors[:email]).to include("can't be blank")
    end

    it "validates consent on final_save" do
      profile.consent_accepted = false
      profile.valid?(:final_save)
      expect(profile.errors[:consent_accepted]).to be_present
    end
  end

  describe "#job_function" do
    it "returns the job function hash" do
      profile.desired_job_function_id = 1
      expect(profile.job_function).to eq({ id: 1, key: "general_dentist", name: "General dentist" })
    end

    it "returns nil when not set" do
      profile.desired_job_function_id = nil
      expect(profile.job_function).to be_nil
    end
  end

  describe "#clinical_role?" do
    it "returns true for dental hygienist" do
      profile.desired_job_function_id = 2
      expect(profile).to be_clinical_role
    end

    it "returns true for specialist" do
      profile.desired_job_function_id = 10
      expect(profile).to be_clinical_role
    end

    it "returns true for general_dentist key" do
      profile.desired_job_function_id = 1
      expect(profile).to be_clinical_role
    end

    it "returns false for other roles" do
      profile.desired_job_function_id = 3
      expect(profile).not_to be_clinical_role
    end
  end

  describe ".job_functions" do
    it "returns 10 job functions" do
      expect(CandidateProfile.job_functions.size).to eq(10)
    end

    it "includes dentist" do
      names = CandidateProfile.job_functions.map { |jf| jf[:name] }
      expect(names).to include("General dentist")
    end
  end

  describe "#preferred_regions_list" do
    it "splits comma-separated regions" do
      profile.preferred_regions = "Amsterdam,Rotterdam"
      expect(profile.preferred_regions_list).to eq(["Amsterdam", "Rotterdam"])
    end

    it "returns empty array when blank" do
      profile.preferred_regions = nil
      expect(profile.preferred_regions_list).to eq([])
    end
  end

  describe "#employment_types_list" do
    it "splits comma-separated types" do
      profile.desired_employment_type = "employed,freelance"
      expect(profile.employment_types_list).to eq(["employed", "freelance"])
    end
  end

  describe "#working_days_list" do
    it "splits comma-separated days" do
      profile.available_working_days = "monday,wednesday,friday"
      expect(profile.working_days_list).to eq(["monday", "wednesday", "friday"])
    end
  end
end
