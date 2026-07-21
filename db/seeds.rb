# frozen_string_literal: true
# Languages
%w[Dutch English German French Spanish Turkish Arabic].each do |name|
  Language.find_or_create_by!(name: name)
end

# Skills by job function
skills_data = {
  1 => { # General dentist
    group: "Dentist",
    skills: %w[Endodontics Restorative_dentistry Pediatric_dentistry Surgery Aligners
               Prosthodontics Periodontology Oral_diagnosis Radiography Anesthesiology]
  },
  2 => { # Dental hygienist
    group: "Dental hygienist",
    skills: %w[Periodontology Prevention Scaling Patient_education Radiography
               Dental_hygiene_instruction Local_anesthesia]
  },
  3 => { # Dental assistant
    group: "Dental assistant",
    skills: %w[Chairside_assistance Sterilization Orthodontics Prevention
               Radiography Impression_taking Instrument_preparation]
  },
  4 => { # Prevention assistant
    group: "Prevention assistant",
    skills: %w[Prevention Scaling Patient_education Oral_hygiene_instruction Radiography]
  },
  5 => { # Paro-prevention assistant
    group: "Paro-prevention assistant",
    skills: %w[Periodontology Prevention Scaling Patient_education Oral_hygiene]
  },
  6 => { # Orthodontic assistant
    group: "Orthodontic assistant",
    skills: %w[Orthodontics Bracket_placement Wire_changes Impression_taking Radiography]
  },
  7 => { # Front-office / receptionist
    group: "Front-office",
    skills: %w[Planning Phone_handling Invoicing Patient_communication Appointment_scheduling
               Insurance_processing CRM]
  },
  8 => { # Practice manager
    group: "Practice manager",
    skills: %w[Team_management Scheduling HR Practice_operations Financial_management
               Marketing Compliance Quality_management]
  },
  9 => { # Dental technician
    group: "Dental technician",
    skills: %w[Prosthetics CAD_CAM Crown_and_bridge Ceramics Implantology
               Orthodontic_appliances 3D_printing]
  },
  10 => { # Specialist
    group: "Specialist",
    skills: %w[Oral_surgery Implantology Orthodontics Periodontology Endodontics
               Pediatric_dentistry Maxillofacial_surgery]
  }
}

skills_data.each do |job_function_id, data|
  data[:skills].each do |skill_name|
    Skill.find_or_create_by!(
      name: skill_name,
      group_name: data[:group],
      job_function_id: job_function_id
    )
  end
end

# Admin user for testing
if Rails.env.development?
  admin = User.find_or_create_by!(email: "admin@example.com") do |u|
    u.password = "password"
    u.role = :admin
  end

  candidate = User.find_or_create_by!(email: "candidate@example.com") do |u|
    u.password = "password"
    u.role = :candidate
  end

  User.find_or_create_by!(email: "recruiter@example.com") do |u|
    u.password = "password"
    u.role = :recruiter
  end
end
