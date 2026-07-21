# frozen_string_literal: true
class Education < ApplicationRecord
  belongs_to :candidate_profile

  validates :study, presence: true

  EDUCATION_LEVELS = %w[mbo hbo bachelor master doctor course].freeze

  validates :level, inclusion: { in: EDUCATION_LEVELS }, allow_blank: true
end
