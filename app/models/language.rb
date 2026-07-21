# frozen_string_literal: true
class Language < ApplicationRecord
  has_many :candidate_languages, dependent: :destroy
  has_many :candidate_profiles, through: :candidate_languages

  validates :name, presence: true, uniqueness: true
end
