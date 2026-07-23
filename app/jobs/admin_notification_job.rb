# frozen_string_literal: true
class AdminNotificationJob < ApplicationJob
  queue_as :default

  def perform(profile_id)
    profile = CandidateProfile.find_by(id: profile_id)
    return unless profile

    User.where(role: [:admin, :recruiter]).pluck(:email).each do |email|
      AdminMailer.candidate_onboarded(profile, email).deliver_later
    end
  end
end
