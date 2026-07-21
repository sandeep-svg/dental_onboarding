# frozen_string_literal: true
class AdminNotificationJob < ApplicationJob
  queue_as :default

  def perform(profile_id)
    profile = CandidateProfile.find(profile_id)
    admin_emails = User.where(role: [:admin, :recruiter]).pluck(:email)

    admin_emails.each do |email|
      AdminMailer.candidate_onboarded(profile, email).deliver_later
    end
  end
end
