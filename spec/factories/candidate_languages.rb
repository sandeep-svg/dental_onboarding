# frozen_string_literal: true
FactoryBot.define do
  factory :candidate_language do
    candidate_profile { nil }
    language { nil }
    level { "MyString" }
  end
end
