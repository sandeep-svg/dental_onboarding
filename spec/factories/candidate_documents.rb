# frozen_string_literal: true
FactoryBot.define do
  factory :candidate_document do
    candidate_profile
    original_filename { "cv.pdf" }
    content_type { "application/pdf" }
    file_size { 1024 }
    parsing_status { "pending" }

    after(:build) do |doc|
      doc.file.attach(
        io: StringIO.new("fake pdf content"),
        filename: doc.original_filename,
        content_type: doc.content_type
      )
    end
  end
end
