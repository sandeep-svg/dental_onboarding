# frozen_string_literal: true
class CandidateLanguage < ApplicationRecord
  belongs_to :candidate_profile
  belongs_to :language

  validates :language_id, uniqueness: { scope: :candidate_profile_id }
  validates :level, inclusion: { in: %w[A1 A2 B1 B2 C1 C2 native fluent],
    message: "%{value} is not a valid language level" }, allow_blank: true
end
