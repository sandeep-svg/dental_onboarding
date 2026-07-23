# frozen_string_literal: true
class CandidateProfile < ApplicationRecord
  belongs_to :user
  has_many :candidate_documents, dependent: :destroy
  has_many :educations, dependent: :destroy
  has_many :work_experiences, dependent: :destroy
  has_many :candidate_skills, dependent: :destroy
  has_many :skills, through: :candidate_skills
  has_many :candidate_languages, dependent: :destroy
  has_many :languages, through: :candidate_languages

  accepts_nested_attributes_for :educations, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :work_experiences, allow_destroy: true, reject_if: :all_blank


  SEARCH_STATUSES = %w[active passive inactive].freeze
  TRANSPORT_OPTIONS = %w[bike scooter public_transport car].freeze
  WORKING_DAYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze
  EMPLOYMENT_TYPES = %w[employed self_employed freelance percentage_based].freeze
  BIG_REGISTRATION_STATUSES = %w[big_registered in_progress under_supervision not_applicable].freeze
  EDUCATION_LEVELS = %w[mbo hbo bachelor master doctor course].freeze

  validates :first_name, :last_name, :email, :phone_number, :city, :country,
    presence: true, on: :final_save
  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/,
    message: "must be a valid email address" }, on: :final_save
  validates :phone_number, format: { with: /\A\+?[\d\s\-().]+\z/,
    message: "must be a valid phone number" }, on: :final_save
  validates :desired_job_function_id, presence: true, on: :final_save
  validates :max_travel_time, presence: true, numericality: { greater_than_or_equal_to: 0 }, on: :final_save
  validates :years_of_experience, presence: true, numericality: { greater_than_or_equal_to: 0 }, on: :final_save
  validates :desired_gross_salary, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :desired_percentage, numericality: { in: 0..100 }, allow_nil: true
  validates :average_daily_revenue, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :consent_accepted, acceptance: true, on: :final_save
  validates :available_from, presence: true, on: :final_save

  validate :validate_preferred_regions, on: :final_save
  validate :validate_employment_type, on: :final_save
  validate :validate_working_days, on: :final_save
  validate :validate_big_fields, on: :final_save
  validate :validate_search_status, on: :final_save
  validate :validate_languages, on: :final_save

  def job_function
    return nil unless desired_job_function_id
    self.class.job_functions.find { |jf| jf[:id] == desired_job_function_id }
  end

  def clinical_role?
    job_function.present? && %w[general_dentist dentist dental_hygienist specialist].include?(job_function[:key])
  end

  def self.job_functions
    [
      { id: 1, key: "general_dentist", name: "General dentist" },
      { id: 2, key: "dental_hygienist", name: "Dental hygienist" },
      { id: 3, key: "dental_assistant", name: "Dental assistant" },
      { id: 4, key: "prevention_assistant", name: "Prevention assistant" },
      { id: 5, key: "paro_prevention_assistant", name: "Paro-prevention assistant" },
      { id: 6, key: "orthodontic_assistant", name: "Orthodontic assistant" },
      { id: 7, key: "front_office", name: "Front-office / receptionist" },
      { id: 8, key: "practice_manager", name: "Practice manager" },
      { id: 9, key: "dental_technician", name: "Dental technician" },
      { id: 10, key: "specialist", name: "Specialist" },
    ]
  end

  def self.regions
    %w[Amsterdam Rotterdam Utrecht The_Hague Eindhoven Groningen Maastricht Other]
  end

  def preferred_regions=(value)
    super(value.is_a?(Array) ? value.reject(&:blank?).join(",") : value)
  end

  def desired_employment_type=(value)
    super(value.is_a?(Array) ? value.reject(&:blank?).join(",") : value)
  end

  def available_working_days=(value)
    super(value.is_a?(Array) ? value.reject(&:blank?).join(",") : value)
  end

  def transport_type=(value)
    super(value.is_a?(Array) ? value.reject(&:blank?).join(",") : value)
  end

  def preferred_regions_list
    return [] if preferred_regions.blank?
    preferred_regions.split(",").map(&:strip)
  end

  def employment_types_list
    return [] if desired_employment_type.blank?
    desired_employment_type.split(",").map(&:strip)
  end

  def working_days_list
    return [] if available_working_days.blank?
    available_working_days.split(",").map(&:strip)
  end

  def transport_types_list
    return [] if transport_type.blank?
    transport_type.split(",").map(&:strip)
  end

  def suggested_skills_list
    return [] if suggested_skills.blank?
    suggested_skills.split(",").map(&:strip)
  end

  def sync_skills(skill_ids)
    return if skill_ids.blank?
    selected = skill_ids.map(&:to_i)
    existing = self.skill_ids
    to_add = selected - existing
    to_remove = existing - selected
    to_add.each { |id| candidate_skills.find_or_create_by(skill_id: id) }
    candidate_skills.where(skill_id: to_remove).destroy_all
  end

  def sync_languages(language_params)
    return if language_params.blank?
    selected = language_params.select { |_, v| v[:selected] == "1" }
    selected_ids = selected.keys.map(&:to_i)
    existing_ids = language_ids
    to_add = selected_ids - existing_ids
    to_remove = existing_ids - selected_ids
    selected.each do |lang_id, data|
      next unless to_add.include?(lang_id.to_i)
      candidate_languages.create(language_id: lang_id.to_i, level: data[:level].presence)
    end
    candidate_languages.where(language_id: to_remove).destroy_all
    selected.each do |lang_id, data|
      next if to_add.include?(lang_id.to_i) || to_remove.include?(lang_id.to_i)
      cl = candidate_languages.find_by(language_id: lang_id.to_i)
      cl&.update(level: data[:level].presence)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[first_name last_name email city desired_job_function_id search_status]
  end

  private

  def validate_preferred_regions
    if preferred_regions.blank?
      errors.add(:preferred_regions, "must have at least one region selected")
    end
  end

  def validate_employment_type
    if desired_employment_type.blank?
      errors.add(:desired_employment_type, "must have at least one type selected")
    end
  end

  def validate_working_days
    if available_working_days.blank?
      errors.add(:available_working_days, "must have at least one day selected")
    end
  end

  def validate_search_status
    if search_status.blank?
      errors.add(:search_status, "must be selected")
    elsif !SEARCH_STATUSES.include?(search_status)
      errors.add(:search_status, "is not a valid status")
    end
  end

  def validate_languages
    if candidate_languages.empty?
      errors.add(:languages, "must have at least one language selected")
    end
  end

  def validate_big_fields
    return unless clinical_role?
    if big_registration_status == "big_registered" && big_number.blank?
      errors.add(:big_number, "is required when BIG registered")
    end
  end
end
