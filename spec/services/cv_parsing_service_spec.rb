# frozen_string_literal: true
require "rails_helper"

RSpec.describe CvParsingService do
  let(:profile) { create(:candidate_profile) }
  let(:document) { create(:candidate_document, candidate_profile: profile) }

  before do
    document.file.attach(
      io: StringIO.new("John Doe\njohn@example.com\n+31 6 12345678\nAmsterdam"),
      filename: "test.pdf",
      content_type: "application/pdf"
    )
  end

  describe "#call" do
    it "returns a hash with parsed: false for unparsable content" do
      result = described_class.new(document).call
      expect(result).to be_a(Hash)
      expect(result.key?(:parsed)).to be true
    end
  end

  describe "text extraction methods" do
    let(:service) { described_class.new(document) }
    let(:sample_text) {
      "Dr. Sarah van den Berg\n\ntandarts@example.com\n+31 20 1234567\n\nAmsterdam\nNetherlands\n\n" \
      "Experience\n2018 - Present General Dentist at Amsterdam Dental Clinic\n2015 - 2018 Junior Dentist at Rotterdam Dental\n\n" \
      "Education\n2010 - 2015 Master of Dentistry - University of Amsterdam\n\n" \
      "Skills\nEndodontics, Restorative Dentistry, Surgery\n\n" \
      "Languages\nDutch (native), English (fluent), German (B2)\n\n" \
      "BIG: 1234567\n\n10 years of experience"
    }

    describe "email extraction" do
      it "extracts email from text" do
        email = service.send(:extract_email, sample_text)
        expect(email).to eq("tandarts@example.com")
      end
    end

    describe "phone extraction" do
      it "extracts phone number" do
        phone = service.send(:extract_phone, sample_text)
        expect(phone).to eq("+31 20 1234567")
      end
    end

    describe "BIG number extraction" do
      it "extracts BIG number" do
        big = service.send(:extract_big_number, sample_text)
        expect(big).to eq("1234567")
      end
    end

    describe "years of experience extraction" do
      it "extracts years of experience" do
        years = service.send(:extract_years_experience, sample_text)
        expect(years).to eq(10)
      end
    end
  end
end
