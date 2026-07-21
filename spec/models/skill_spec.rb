# frozen_string_literal: true
require "rails_helper"

RSpec.describe Skill, type: :model do
  it { is_expected.to have_many(:candidate_skills).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }
end
