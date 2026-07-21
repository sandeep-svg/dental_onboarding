# frozen_string_literal: true
FactoryBot.define do
  factory :candidate_profile do
    user
    first_name { "John" }
    last_name { "Doe" }
    email { "john@example.com" }
    phone_number { "+31 6 12345678" }
    city { "Amsterdam" }
    country { "Netherlands" }
    desired_job_function_id { 1 }
    max_travel_time { 30 }
    years_of_experience { 5 }
    available_from { Date.tomorrow }
    search_status { "active" }
    consent_accepted { true }
    onboarding_completed { false }
    parsing_status { "pending" }

    after(:create) do |profile|
      lang = Language.first || Language.create!(name: "English")
      profile.candidate_languages.find_or_create_by!(language: lang)
    end

    trait :completed do
      onboarding_completed { true }
      parsing_status { "completed" }
    end

    trait :with_education do
      after(:create) do |profile|
        create(:education, candidate_profile: profile)
      end
    end

    trait :with_work_experience do
      after(:create) do |profile|
        create(:work_experience, candidate_profile: profile)
      end
    end

    trait :clinical do
      desired_job_function_id { 1 }
    end
  end
end
