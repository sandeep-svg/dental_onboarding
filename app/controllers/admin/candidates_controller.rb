# frozen_string_literal: true
class Admin::CandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @candidates = CandidateProfile.includes(:user).order(created_at: :desc)
  end

  def show
    @profile = CandidateProfile.find(params[:id])
    @document = @profile.candidate_documents.last
  end

  private

  def require_admin
    unless current_user.admin_or_recruiter?
      redirect_to root_path, alert: "You are not authorized to view this page."
    end
  end
end
