# frozen_string_literal: true
class AdminMailer < ApplicationMailer
  def candidate_onboarded(profile, admin_email)
    @profile = profile
    @user = profile.user
    mail(to: admin_email, subject: "New candidate onboarded: #{@profile.first_name} #{@profile.last_name}")
  end
end
