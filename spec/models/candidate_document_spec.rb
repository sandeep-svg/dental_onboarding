# frozen_string_literal: true
require "rails_helper"

RSpec.describe CandidateDocument, type: :model do
  subject(:document) { build(:candidate_document) }

  it { is_expected.to belong_to(:candidate_profile) }

  describe "validations" do
    it "validates file type" do
      document.file.attach(
        io: StringIO.new("fake pdf content"),
        filename: "test.pdf",
        content_type: "application/pdf"
      )
      document.valid?
      expect(document.errors[:file]).to be_empty
    end

    it "rejects invalid file type" do
      document.file.attach(
        io: StringIO.new("image content"),
        filename: "test.png",
        content_type: "image/png"
      )
      document.valid?
      expect(document.errors[:file]).to include("must be a PDF, DOC, or DOCX file")
    end
  end
end
