# frozen_string_literal: true
class CvParsingService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def call
    text = extract_text
    return { parsed: false, error: "Could not extract text" } if text.blank?

    {
      parsed: true,
      first_name: extract_first_name(text),
      last_name: extract_last_name(text),
      email: extract_email(text),
      phone_number: extract_phone(text),
      city: extract_city(text),
      country: extract_country(text),
      languages: extract_languages(text),
      current_job_title: extract_current_job_title(text),
      education: extract_education(text),
      work_experience: extract_work_experience(text),
      skills: extract_skills(text),
      big_number: extract_big_number(text),
      years_of_experience: extract_years_experience(text),
      professional_summary: extract_summary(text),
      raw_text: text
    }
  end

  private

  def extract_text
    case document.content_type
    when "application/pdf"
      extract_pdf_text
    when "application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      extract_docx_text
    end
  end

  def extract_pdf_text
    document.file.download.then { |io| PDF::Reader.new(StringIO.new(io)).pages.map(&:text).join("\n") }
  rescue => e
    Rails.logger.error "PDF extraction error: #{e.message}"
    nil
  end

  def extract_docx_text
    document.file.download.then { |io| Docx::Document.new(StringIO.new(io)).paragraphs.map(&:text).join("\n") }
  rescue => e
    Rails.logger.error "DOCX extraction error: #{e.message}"
    nil
  end

  def extract_email(text)
    text[/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/]
  end

  def extract_phone(text)
    patterns = [
      /\+\d{1,3}[\s-]?\d{1,4}[\s-]?\d{1,4}[\s-]?\d{1,9}/,
      /0\d{1,2}[\s-]?\d{1,4}[\s-]?\d{1,4}[\s-]?\d{1,4}/,
      /\(\d{2,4}\)[\s-]?\d{1,4}[\s-]?\d{1,4}[\s-]?\d{1,4}/
    ]
    patterns.each do |pattern|
      match = text[pattern]
      return match.strip if match
    end
    nil
  end

  def extract_first_name(text)
    lines = text.lines.map(&:strip).reject(&:blank?)
    name_line = lines.first
    return nil unless name_line
    parts = name_line.split(/\s+/)
    name = parts.first
    return nil unless name

    name = name.split("(").first.strip
    name = name.titleize if name == name.upcase
    name
  end

  def extract_last_name(text)
    lines = text.lines.map(&:strip).reject(&:blank?)
    name_line = lines.first
    return nil unless name_line
    parts = name_line.split(/\s+/)
    return nil if parts.length < 2
    name = parts.last
    name = name.titleize if name == name.upcase
    name
  end

  def extract_city(text)
    city_match = text.match(/(?:City|Location|Place|Plaats|Woonplaats|Stad)[:\s]+([A-Za-z\s\-]+)/i)
    return city_match[1].strip.titleize if city_match

    address_match = text.match(/\|\s*([A-Za-z\s\-]+),[\s]*([A-Za-z\s\-]+)/)
    if address_match
      city = address_match[1].strip
      return city.titleize if city.length < 30
    end

    common_cities = %w[Amsterdam Rotterdam Utrecht The\ Hague Den\ Haag Eindhoven Groningen Maastricht
      Haarlem Leiden Arnhem Nijmegen Breda Tilburg Almere
      Hyderabad Bangalore Mumbai Delhi Chennai Kolkata
      New\ York London Berlin Paris Sydney Toronto]
    common_cities.each do |city|
      return city if text.include?(city)
    end
    nil
  end

  def extract_country(text)
    country_match = text.match(/(?:Country|Land)[:\s]+([A-Za-z\s\-]+)/i)
    return country_match[1].strip if country_match

    if text.match?(/\b(?:Netherlands|Nederland|Holland)\b/i)
      return "Netherlands"
    elsif text.match?(/\bIndia\b/i)
      return "India"
    elsif text.match?(/\b(?:Belgium|België)\b/i)
      return "Belgium"
    elsif text.match?(/\b(?:Germany|Duitsland)\b/i)
      return "Germany"
    elsif text.match?(/\bUnited\s*Kingdom|UK|England\b/i)
      return "United Kingdom"
    elsif text.match?(/\bUnited\s*States|USA|U\.S\.A\.?\b/i)
      return "United States"
    end
    nil
  end

  def extract_languages(text)
    languages = []
    lang_section = text.match(/(?:Languages?|Talen|Taal)[:\n]+(.+?)(?:\n\n|\Z)/im)
    if lang_section
      lang_section[1].split(/[,;\n]/).each do |lang|
        lang = lang.strip
        next if lang.blank?
        level = nil
        level_match = lang.match(/(.+?)\s*[\(\[–\-]\s*(A1|A2|B1|B2|C1|C2|native|fluent|moedertaal|vloeiend)\s*[\)\]–\-]?\s*$/i)
        if level_match
          lang = level_match[1].strip
          level = level_match[2].downcase
          level = "native" if %w[moedertaal].include?(level)
          level = "fluent" if %w[vloeiend].include?(level)
        end
        languages << { name: lang, level: level }
      end
    end
    languages
  end

  def extract_current_job_title(text)
    exp_section = extract_section(text, [
      /(?:PROFESSIONAL EXPERIENCE|Experience|Work|Work\s*Experience|Werkervaring|Employment|Career)[:\n]+(.+?)(?:\n\n(?:Education|Opleiding|NOTABLE|Skills|Vaardigheden|Languages|Talen)\b|\Z)/im,
    ])
    return nil unless exp_section

    lines = exp_section.lines.map(&:strip).reject(&:blank?)
    return nil if lines.empty?

    first_entry = lines.first
    date_match = first_entry.match(/\d{4}/)
    if date_match
      company = first_entry.sub(date_match[0], "").strip
      return company
    end
    first_entry
  end

  def extract_education(text)
    records = []
    edu_section = extract_section(text, [
      /(?:EDUCATION|Education|Opleiding|Opleidingen|Studies)[:\n]+(.+?)(?:\n\n(?:Experience|Work|Ervaring|Werkervaring|Skills|Vaardigheden|ADDITIONAL|Languages|Talen|REFERENCES|NOTABLE)\b|\Z)/im,
    ])
    return records unless edu_section

    entries = edu_section.split(/\n(?=\d{4}|•)/)
    entries.each do |entry|
      entry = entry.strip.gsub(/\s{2,}/, " ")
      next if entry.blank?

      dates = entry.scan(/(\d{4})/)

      level_keywords = %w[B.Tech Bachelor Master Doctor PhD MBO HBO Associate Diploma]
      level = level_keywords.find { |kw| entry.match?(/\b#{kw}\b/i) }
      level = level&.downcase
      level = "bachelor" if level == "b.tech"

      parts = entry.split(/[—–-]/).map(&:strip)
      study = nil
      institution = nil
      if parts.length >= 3
        study = parts[0].sub(/^[^A-Za-z]*/, "").strip
        institution = parts[1].strip
      elsif parts.length == 2
        if parts[0].match?(/\b(B\.Tech|Bachelor|Master|M\.Sc|B\.Sc|PhD|MBA|Diploma|Associate)\b/i)
          study = parts[0].strip
          institution = parts[1].strip
        else
          institution = parts[0].strip
        end
      elsif parts.length == 1
        institution = parts[0].strip
      end

      records << {
        institution: institution,
        study: study,
        level: level,
        start_date: dates.first&.first,
        end_date: dates.last&.first
      }
    end
    records.reject { |r| r[:institution].blank? && r[:study].blank? }
  end

  def extract_work_experience(text)
    records = []
    work_section = extract_section(text, [
      /(?:PROFESSIONAL EXPERIENCE|Experience|Work|Work\s*Experience|Werkervaring|Employment|Career)[:\n]+(.+?)(?:\n\n(?:EDUCATION|Education|Opleiding|NOTABLE|PROJECTS|Skills|Vaardigheden|Languages|Talen)\b|\Z)/im,
    ])
    return records unless work_section

    lines = work_section.lines.map(&:strip)
    cleaned = []
    lines.each do |line|
      next if line.blank?
      if cleaned.any? && line.start_with?(" ") && !line.match?(/\d{4}/)
        cleaned[-1] += " " + line.strip
      else
        cleaned << line.strip
      end
    end

    current_entry = nil
    cleaned.each do |line|
      if line.match?(/\b\d{4}\b.*(?:Present|present|Current|current)/) || (line.match?(/\b\d{4}\b/) && !line.match?(/^[A-Z][a-z]+[ed]/))
        if current_entry
          records << current_entry
        end
        current_entry = { company_name: nil, job_title: nil, responsibilities: nil, current_job: false, start_date: nil, end_date: nil }
        dates = line.scan(/(\d{4})/)
        current_entry[:start_date] = dates.first&.first
        current_entry[:end_date] = dates.last&.first if dates.length > 1
        current_entry[:current_job] = line.match?(/present/i)
        parts = line.split(/\s{3,}/)
        current_entry[:company_name] = parts.first.strip
      elsif current_entry && current_entry[:job_title].nil? && line.length < 120 && !line.match?(/^(Architected|Built|Improved|Delivered|Led|Upgraded|Implemented|Enhanced|Developed|Mentored|Reduced|Migrated)/)
        current_entry[:job_title] = line
      elsif current_entry
        current_entry[:responsibilities] ||= ""
        current_entry[:responsibilities] += " " + line.gsub(/^[\s•\-*]+/, "").strip
      end
    end
    records << current_entry if current_entry
    records
  end

  def extract_skills(text)
    skill_section = extract_section(text, [
      /(?:TECHNICAL SKILLS|Skills|Vaardigheden|Competencies|Expertise)[:\n]+(.+?)(?:\n\n(?:PROFESSIONAL|Languages|Talen|Education|Opleiding|Experience|Ervaring|PROJECTS|REFERENCES|ADDITIONAL)\b|\Z)/im,
    ])
    return [] unless skill_section

    skills = []
    skill_section.split("\n").each do |line|
      line = line.strip
      next if line.blank?
      if line.include?(":")
        parts = line.split(":")
        next if parts.length < 2
        values = parts[1].strip.gsub(/\([^)]+\)/, "")
        values.split(",").each do |s|
          skill = s.strip.gsub(/\s{2,}/, " ").downcase
          skills << skill unless skill.blank? || skill.length > 30
        end
      else
        line.split(/[,;\n•\-*]/).each do |s|
          skill = s.strip.gsub(/\s{2,}/, " ").downcase
          skills << skill unless skill.blank? || skill.length > 30
        end
      end
    end
    skills.uniq
  end

  def extract_big_number(text)
    match = text.match(/\bBIG[:\s]*(?:Registrat(?:ie|ion)[:\s]*)?(\d{6,10})\b/i)
    match&.captures&.first
  end

  def extract_years_experience(text)
    match = text.match(/(\d+[\.\d]*)\+?\s*(?:years?|jaar)\s*(?:of\s+)?(?:\w+\s+){0,2}(?:experience|ervaring|practice|werk)/i)
    match&.captures&.first&.to_f
  end

  def extract_summary(text)
    summary_section = extract_section(text, [
      /(?:SUMMARY|Summary|Profile|Professional\s*Summary|Samenvatting|Profiel)[:\n]+(.+?)(?:\n\n(?:KEY|TECHNICAL|PROFESSIONAL|Experience|Work|Education|Skills|Languages)\b|\Z)/im
    ])
    summary_section&.strip
  end

  def extract_section(text, patterns)
    patterns.each do |pattern|
      match = text.match(pattern)
      return match[1].strip if match
    end
    nil
  end
end
