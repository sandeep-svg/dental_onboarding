# frozen_string_literal: true
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :candidate_profile, dependent: :destroy

  enum :role, { candidate: 0, admin: 1, recruiter: 2 }, default: :candidate

  validates :role, inclusion: { in: roles.keys }

  def admin_or_recruiter?
    admin? || recruiter?
  end
end
