# frozen_string_literal: true
FactoryBot.define do
  factory :work_experience do
    candidate_profile
    job_title { "General Dentist" }
    company_name { "Dental Clinic Amsterdam" }
    start_date { Date.new(2020, 7, 1) }
  end
end
