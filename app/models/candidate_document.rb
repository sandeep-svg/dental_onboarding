# frozen_string_literal: true
class CandidateDocument < ApplicationRecord
  belongs_to :candidate_profile
  has_one_attached :file

  PARSING_STATUSES = %w[pending processing completed failed].freeze
  ALLOWED_CONTENT_TYPES = %w[application/pdf application/msword
    application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze

  validates :parsing_status, inclusion: { in: PARSING_STATUSES }, allow_nil: true
  validates :file, presence: true
  validate :file_type_valid, if: -> { file.attached? }
  validate :file_size_valid, if: -> { file.attached? }

  def file_type_valid
    unless file.content_type.in?(ALLOWED_CONTENT_TYPES)
      errors.add(:file, "must be a PDF, DOC, or DOCX file")
    end
  end

  def file_size_valid
    max_size = ENV.fetch("MAX_CV_SIZE_MB", 25).to_i.megabytes
    if file.byte_size > max_size
      errors.add(:file, "must be less than #{max_size / 1.megabyte} MB")
    end
  end
end
