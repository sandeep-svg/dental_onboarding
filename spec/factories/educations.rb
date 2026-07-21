# frozen_string_literal: true
FactoryBot.define do
  factory :education do
    candidate_profile
    institution { "University of Amsterdam" }
    study { "Dentistry" }
    level { "master" }
    start_date { Date.new(2015, 9, 1) }
    end_date { Date.new(2020, 6, 30) }
  end
end
