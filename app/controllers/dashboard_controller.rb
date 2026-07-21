# frozen_string_literal: true
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @profile = current_user.candidate_profile
    @document = @profile&.candidate_documents&.last
  end
end
