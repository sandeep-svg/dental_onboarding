# frozen_string_literal: true
FactoryBot.define do
  factory :candidate_skill do
    candidate_profile { nil }
    skill { nil }
    source { "MyString" }
  end
end
