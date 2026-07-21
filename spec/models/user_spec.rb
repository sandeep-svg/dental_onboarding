# frozen_string_literal: true
require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "associations" do
    it { is_expected.to have_one(:candidate_profile).dependent(:destroy) }
  end

  describe "enums" do
    it "defines roles" do
      expect(User.roles).to eq({ "candidate" => 0, "admin" => 1, "recruiter" => 2 })
    end

    it "defaults to candidate role" do
      u = User.create!(email: "test@example.com", password: "password")
      expect(u).to be_candidate
    end
  end

  describe "devise modules" do
    it "authenticates with valid credentials" do
      user.save!
      expect(User.find_for_authentication(email: user.email)).to eq(user)
    end

    it "rejects invalid password" do
      user.save!
      expect(user.valid_password?("wrong")).to be false
    end
  end
end
