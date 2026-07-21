# frozen_string_literal: true
class Skill < ApplicationRecord
  has_many :candidate_skills, dependent: :destroy
  has_many :candidate_profiles, through: :candidate_skills

  validates :name, presence: true, uniqueness: { scope: :job_function_id }

  scope :by_job_function, ->(job_function_id) { where(job_function_id: job_function_id) }
  scope :uncategorized, -> { where(job_function_id: nil) }
end
