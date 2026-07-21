# frozen_string_literal: true
class ParseCandidateCvJob < ApplicationJob
  queue_as :default

  def perform(document_id)
    document = CandidateDocument.find_by(id: document_id)
    return unless document

    document.update!(parsing_status: "processing")

    begin
      result = CvParsingService.new(document).call

      if result[:parsed]
        profile = document.candidate_profile
        apply_parsed_data(profile, result)
        document.update!(parsing_status: "completed", parsed_at: Time.current)
        profile.update_columns(parsing_status: "completed")
      else
        document.update!(parsing_status: "failed")
        profile.update_columns(parsing_status: "failed")
      end
    rescue => e
      Rails.logger.error "CV parsing failed for document #{document_id}: #{e.message}"
      document.update!(parsing_status: "failed")
      document.candidate_profile&.update_columns(parsing_status: "failed")
    end
  end

  private

  def apply_parsed_data(profile, result)
    profile.educations.destroy_all
    profile.work_experiences.destroy_all
    profile.candidate_skills.destroy_all
    profile.candidate_languages.destroy_all

    updates = {}
    updates[:first_name] = result[:first_name] if result[:first_name] && profile.first_name.blank?
    updates[:last_name] = result[:last_name] if result[:last_name] && profile.last_name.blank?
    updates[:email] = result[:email] if result[:email] && profile.email.blank?
    updates[:phone_number] = result[:phone_number] if result[:phone_number] && profile.phone_number.blank?
    updates[:city] = result[:city] if result[:city] && profile.city.blank?
    updates[:country] = result[:country] if result[:country] && profile.country.blank?
    updates[:professional_summary] = result[:professional_summary] if result[:professional_summary] && profile.professional_summary.blank?
    updates[:big_number] = result[:big_number] if result[:big_number] && profile.big_number.blank?
    updates[:years_of_experience] = result[:years_of_experience] if result[:years_of_experience] && profile.years_of_experience.blank?

    profile.update(updates) unless updates.empty?

    # Create education records
    if result[:education].present?
      result[:education].each do |edu|
        profile.educations.find_or_create_by(
          institution: edu[:institution],
          study: edu[:study]
        ) do |e|
          e.level = edu[:level] if edu[:level]
          e.start_date = edu[:start_date] if edu[:start_date]
          e.end_date = edu[:end_date] if edu[:end_date]
        end
      end
    end

    # Create work experience records
    if result[:work_experience].present?
      result[:work_experience].each do |we|
        profile.work_experiences.find_or_create_by(
          job_title: we[:job_title],
          company_name: we[:company_name]
        ) do |w|
          w.responsibilities = we[:responsibilities] if we[:responsibilities]
          w.start_date = we[:start_date] if we[:start_date]
          w.end_date = we[:end_date] if we[:end_date]
          w.current_job = we[:current_job] if we.key?(:current_job)
        end
      end
    end

    if result[:skills].present?
      parsed_skills = result[:skills].map { |s| s.downcase.gsub(/[_\-\s]+/, "") }
      matched = []
      Skill.all.each do |skill|
        normalized = skill.name.downcase.gsub(/[_\-\s]+/, "")
        if parsed_skills.any? { |ps| ps.include?(normalized) || normalized.include?(ps) }
          profile.candidate_skills.find_or_create_by(skill_id: skill.id)
          matched << normalized
        end
      end
      unknown = result[:skills].reject { |s| matched.include?(s.downcase.gsub(/[_\-\s]+/, "")) }
      profile.update(suggested_skills: unknown.join(", ")) if unknown.any?
    end

    # Match languages
    if result[:languages].present?
      result[:languages].each do |lang_data|
        language = Language.find_by("LOWER(name) = ?", lang_data[:name].downcase.strip)
        next unless language
        profile.candidate_languages.find_or_create_by(language_id: language.id) do |cl|
          cl.level = lang_data[:level] if lang_data[:level]
        end
      end
    end
  end
end
