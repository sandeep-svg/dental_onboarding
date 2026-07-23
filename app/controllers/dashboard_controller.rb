# frozen_string_literal: true
class DashboardController < ApplicationController
  def index
    @profile = current_user.candidate_profile
    @document = @profile&.candidate_documents&.last
  end
end
