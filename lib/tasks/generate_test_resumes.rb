#!/usr/bin/env ruby
# frozen_string_literal: true

require "zip"
require "prawn"
require "fileutils"

OUTDIR = "/Users/sandeep/Documents/dental_onboarding"

PROFILES = [
  {
    prefix: "hygienist",
    name: "Marieke Jansen",
    email: "marieke.jansen@email.nl",
    phone: "+31 6 23456789",
    city: "Utrecht",
    country: "Netherlands",
    role: "Dental Hygienist",
    summary: "Dedicated dental hygienist with 6+ years of clinical experience. Skilled in periodontal therapy, preventive care, and patient education. Committed to promoting oral health and preventing dental disease in both children and adults.",
    experience: [
      { title: "Senior Dental Hygienist | Mondzorg Utrecht", period: "Sep 2019 - Present", bullets: ["Provided periodontal scaling and root planing treatments", "Educated patients on proper oral hygiene techniques", "Conducted oral cancer screenings and risk assessments", "Collaborated with dentists on comprehensive treatment plans"] },
      { title: "Dental Hygienist | Tandartspraktijk De Pijp", period: "Jun 2016 - Aug 2019", bullets: ["Performed professional dental cleanings and fluoride applications", "Applied sealants and administered local anesthesia", "Assisted in periodontal maintenance programs", "Maintained accurate patient records and treatment notes"] }
    ],
    education: [
      { degree: "Bachelor of Oral Health (Mondzorgkunde)", school: "Hogeschool Utrecht", period: "2013 - 2016" }
    ],
    skills: "Periodontal Therapy, Scaling & Root Planing, Oral Health Education, Digital Radiography, Local Anesthesia Administration, Preventive Dentistry, Pediatric Hygiene",
    languages: "Dutch (Native), English (C1)",
    big_number: "BIG: 9876543",
    years_exp: "6+ years of experience"
  },
  {
    prefix: "orthodontist",
    name: "David Chen",
    email: "d.chen@orthodontiepraktijk.nl",
    phone: "+31 6 34567890",
    city: "Den Haag",
    country: "Netherlands",
    role: "Orthodontist",
    summary: "Board-certified orthodontist with 9+ years of specialized practice. Expertise in clear aligner therapy, fixed appliances, and surgical orthodontics. Passionate about creating beautiful smiles with minimally invasive techniques.",
    experience: [
      { title: "Orthodontist | Den Haag Orthodontie Centrum", period: "Jan 2018 - Present", bullets: ["Treat over 200 active patients using braces and Invisalign", "Developed digital treatment planning workflows using 3D scanning", "Performed interdisciplinary cases with oral surgeons and periodontists", "Reduced average treatment time by 15% through optimized protocols"] },
      { title: "Associate Orthodontist | Rotterdam Orthodontie", period: "Mar 2015 - Dec 2017", bullets: ["Managed full orthodontic caseload of 150+ patients", "Specialized in early intervention and growth modification", "Utilized CBCT imaging for complex treatment planning", "Achieved 98% patient satisfaction in post-treatment surveys"] },
      { title: "Orthodontic Resident | UMC Groningen", period: "Sep 2012 - Feb 2015", bullets: ["Completed 3-year postgraduate residency in orthodontics", "Published research on 3D imaging in treatment planning", "Presented at Dutch Orthodontic Society annual conference"] }
    ],
    education: [
      { degree: "Master of Dentistry (Tandheelkunde)", school: "Rijksuniversiteit Groningen", period: "2006 - 2011" },
      { degree: "Postgraduate Certificate in Orthodontics", school: "Radboud Universiteit Nijmegen", period: "2017" }
    ],
    skills: "Fixed Orthodontic Appliances, Clear Aligner Therapy (Invisalign), 3D Digital Scanning & CBCT, Surgical Orthodontics, Growth Modification, Interdisciplinary Treatment Planning",
    languages: "Dutch (Fluent), English (Native), Mandarin (B2), German (A2)",
    big_number: "BIG: 1122334",
    years_exp: "9+ years of clinical experience"
  },
  {
    prefix: "manager",
    name: "Fatima Al-Rashid",
    email: "fatima.al@tandartspraktijk.nl",
    phone: "+31 6 45678901",
    city: "Rotterdam",
    country: "Netherlands",
    role: "Practice Manager",
    summary: "Experienced dental practice manager with 7+ years in healthcare operations. Proven track record improving practice efficiency, patient retention, and revenue growth. Skilled in team leadership, financial management, and regulatory compliance.",
    experience: [
      { title: "Practice Manager | Tandartspraktijk Rotterdam Zuid", period: "Mar 2019 - Present", bullets: ["Manage daily operations for a 6-chair dental practice with 15 staff", "Increased annual revenue by 30% through optimized scheduling and upselling", "Implemented digital patient management system reducing admin time by 25%", "Maintain compliance with KNMT guidelines, privacy regulations, and BIG registrations"] },
      { title: "Front Office Coordinator | Mondzorg Centrum Rotterdam", period: "Jun 2015 - Feb 2019", bullets: ["Supervised front desk team of 4 receptionists", "Handled patient complaints and improved satisfaction scores by 40%", "Managed insurance claims processing with 99% accuracy rate", "Coordinated specialist referrals and treatment authorization"] }
    ],
    education: [
      { degree: "Master in Healthcare Management", school: "Erasmus Universiteit Rotterdam", period: "2013 - 2015" },
      { degree: "Bachelor in Business Administration", school: "Hogeschool Rotterdam", period: "2009 - 2012" }
    ],
    skills: "Practice Operations, Team Leadership (15+ staff), Budgeting & Financial Planning, Patient Relations, Regulatory Compliance (KNMT, WGBO, AVG), Digital Practice Management (Orisline, DentFlow), Marketing & Patient Acquisition",
    languages: "Dutch (Fluent), English (Fluent), Arabic (Native), French (B1)",
    big_number: "BSN: 9988776",
    years_exp: "7+ years of experience"
  },
  {
    prefix: "experienced_dentist",
    name: "Carlos Mendez",
    email: "c.mendez@dentalclinic.nl",
    phone: "+31 6 56789012",
    city: "Eindhoven",
    country: "Netherlands",
    role: "General Dentist",
    summary: "Highly experienced general dentist with 15+ years of diverse clinical practice across three countries. Expertise in complex restorative cases, implant prosthetics, and full-mouth rehabilitation. Dedicated to evidence-based dentistry and continuing education.",
    experience: [
      { title: "Lead Dentist | Eindhoven Dental Excellence", period: "Feb 2014 - Present", bullets: ["Owner-operator of a thriving general practice with 2000+ active patients", "Perform implant placements with 98% success rate over 500+ cases", "Specialize in full-mouth rehabilitation using CAD/CAM technology", "Mentor 2 associate dentists and 3 dental hygienists"] },
      { title: "Associate Dentist | Klinik Für Zahnmedizin München", period: "Sep 2011 - Jan 2014", bullets: ["Performed advanced restorative and prosthodontic procedures", "Built referral network for implant and cosmetic cases", "Maintained 95% insurance claim approval rate"] },
      { title: "General Dentist | Clínica Dental Barcelona", period: "Jul 2008 - Aug 2011", bullets: ["Provided comprehensive dental care in high-volume urban practice", "Developed community outreach program for underserved populations", "Volunteered for dental missions in Morocco and Senegal"] }
    ],
    education: [
      { degree: "Doctor of Dental Surgery (Licenciatura en Odontología)", school: "Universitat de Barcelona", period: "2002 - 2007" },
      { degree: "Postgraduate Diploma in Implantology", school: "Universiteit van Amsterdam (ACTA)", period: "2016 - 2017" }
    ],
    skills: "Implantology & Implant Prosthetics, Full-Mouth Rehabilitation, CAD/CAM Restorations, Endodontic Microsurgery, Periodontal Surgery, Cosmetic Dentistry (Veneers, Bonding), Cerec, CBCT Interpretation, Conscious Sedation",
    languages: "Spanish (Native), Dutch (C1), English (C2), German (B2), French (A2)",
    big_number: "BIG: 5566778",
    years_exp: "15+ years of experience"
  }
]

def gen_pdf(path, profile)
  Prawn::Document.generate(path, page_size: "A4", margin: [50, 50, 50, 50]) do |pdf|
    pdf.font_size(22) { pdf.text profile[:name], style: :bold }
    pdf.move_down 6
    pdf.font_size(10) do
      pdf.text "#{profile[:email]} | #{profile[:phone]}"
      pdf.text "#{profile[:city]} | #{profile[:country]}"
    end
    pdf.move_down 12

    pdf.font_size(13) { pdf.text "Professional Summary", style: :bold }
    pdf.move_down 4
    pdf.font_size(10) { pdf.text profile[:summary] }
    pdf.move_down 12

    pdf.font_size(13) { pdf.text "Work Experience", style: :bold }
    pdf.move_down 4
    profile[:experience].each do |exp|
      pdf.font_size(11) { pdf.text exp[:title], style: :bold }
      pdf.font_size(10) { pdf.text exp[:period], style: :italic }
      exp[:bullets].each { |b| pdf.font_size(10) { pdf.text "• #{b}", indent_paragraphs: 10 } }
      pdf.move_down 6
    end
    pdf.move_down 4

    pdf.font_size(13) { pdf.text "Education", style: :bold }
    pdf.move_down 4
    profile[:education].each do |edu|
      pdf.font_size(11) { pdf.text edu[:degree], style: :bold }
      pdf.font_size(10) { pdf.text "#{edu[:school]} | #{edu[:period]}", indent_paragraphs: 10 }
      pdf.move_down 4
    end
    pdf.move_down 8

    pdf.font_size(13) { pdf.text "Skills", style: :bold }
    pdf.move_down 4
    pdf.font_size(10) { pdf.text profile[:skills] }
    pdf.move_down 8

    pdf.font_size(13) { pdf.text "Languages", style: :bold }
    pdf.move_down 4
    pdf.font_size(10) { pdf.text profile[:languages] }
    pdf.move_down 8

    pdf.font_size(13) { pdf.text "Registration", style: :bold }
    pdf.move_down 4
    pdf.font_size(10) { pdf.text profile[:big_number] }
    pdf.move_down 4
    pdf.font_size(10) { pdf.text profile[:years_exp] }
  end
end

def gen_ooxml(path, profile)
  doc_xml = <<~XML
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
      <w:body>
        <w:p><w:r><w:rPr><w:sz w:val="44"/><w:b w:val="1"/></w:rPr><w:t>#{profile[:name]}</w:t></w:r></w:p>
        <w:p/>
        <w:p><w:r><w:rPr><w:b w:val="1"/></w:rPr><w:t>Email:</w:t></w:r><w:r><w:t> #{profile[:email]} | Phone: #{profile[:phone]}</w:t></w:r></w:p>
        <w:p><w:r><w:t>City: #{profile[:city]} | Country: #{profile[:country]}</w:t></w:r></w:p>
        <w:p/>
        <w:p><w:r><w:rPr><w:sz w:val="28"/><w:b w:val="1"/></w:rPr><w:t>Professional Summary</w:t></w:r></w:p>
        <w:p><w:r><w:t>#{profile[:summary]}</w:t></w:r></w:p>
        <w:p/>
        <w:p><w:r><w:rPr><w:sz w:val="28"/><w:b w:val="1"/></w:rPr><w:t>Work Experience</w:t></w:r></w:p>
        #{profile[:experience].map { |exp|
          lines = [%(<w:p><w:r><w:rPr><w:b w:val="1"/></w:rPr><w:t>#{esc(exp[:title])}</w:t></w:r></w:p>),
                   %(<w:p><w:r><w:t>#{exp[:period]}</w:t></w:r></w:p>)]
          exp[:bullets].each { |b| lines << %(<w:p><w:r><w:t>• #{esc(b)}</w:t></w:r></w:p>) }
          lines << "<w:p/>"
          lines.join("\n        ")
        }.join("\n        ")}
        <w:p><w:r><w:rPr><w:sz w:val="28"/><w:b w:val="1"/></w:rPr><w:t>Education</w:t></w:r></w:p>
        #{profile[:education].map { |edu|
          %(<w:p><w:r><w:rPr><w:b w:val="1"/></w:rPr><w:t>#{esc(edu[:degree])}</w:t></w:r></w:p>
        <w:p><w:r><w:t>#{esc(edu[:school])} | #{edu[:period]}</w:t></w:r></w:p>)
        }.join("\n        ")}
        <w:p/>
        <w:p><w:r><w:rPr><w:sz w:val="28"/><w:b w:val="1"/></w:rPr><w:t>Skills</w:t></w:r></w:p>
        <w:p><w:r><w:t>#{esc(profile[:skills])}</w:t></w:r></w:p>
        <w:p/>
        <w:p><w:r><w:rPr><w:sz w:val="28"/><w:b w:val="1"/></w:rPr><w:t>Languages</w:t></w:r></w:p>
        <w:p><w:r><w:t>#{esc(profile[:languages])}</w:t></w:r></w:p>
        <w:p/>
        <w:p><w:r><w:rPr><w:sz w:val="28"/><w:b w:val="1"/></w:rPr><w:t>Registration</w:t></w:r></w:p>
        <w:p><w:r><w:t>#{esc(profile[:big_number])}</w:t></w:r></w:p>
        <w:p><w:r><w:t>#{esc(profile[:years_exp])}</w:t></w:r></w:p>
      </w:body>
    </w:document>
  XML

  entries = {
    "_rels/.rels" => <<~XML,
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
      </Relationships>
    XML
    "[Content_Types].xml" => <<~XML,
      <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
        <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
        <Default Extension="xml" ContentType="application/xml"/>
        <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
        <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
      </Types>
    XML
    "word/_rels/document.xml.rels" => '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>',
    "word/styles.xml" => <<~XML,
      <w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style>
      </w:styles>
    XML
    "word/document.xml" => doc_xml
  }

  Zip::OutputStream.write_buffer do |zos|
    entries.each { |name, content| zos.put_next_entry(name); zos.write(content) }
  end.tap { |buffer| File.write(path, buffer.string) }

  # For .doc, also create a copy (Word will open .doc OOXML files)
  FileUtils.cp(path, path.sub(/\.docx$/, ".doc")) if path.end_with?(".docx")
end

def esc(str)
  str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;").gsub("'", "&apos;").gsub('"', "&quot;")
end

PROFILES.each do |profile|
  base = File.join(OUTDIR, "test_#{profile[:prefix]}")

  pdf_path = "#{base}.pdf"
  puts "Generating #{pdf_path}..."
  gen_pdf(pdf_path, profile)

  docx_path = "#{base}.docx"
  puts "Generating #{docx_path}..."
  gen_ooxml(docx_path, profile)

  puts ""
end

puts "\nAll files generated in #{OUTDIR}:"
Dir.glob("#{OUTDIR}/test_*.{pdf,doc,docx}").each { |f| puts "  #{File.basename(f)} (#{File.size(f)} bytes)" }
