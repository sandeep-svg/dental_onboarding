# Dental Onboarding

A Rails 8.1 application for candidate onboarding with CV parsing. Built for a dental recruitment platform.

## Features

- **Two-step onboarding flow**: Upload CV → Review & complete profile
- **CV parsing**: Extracts candidate data from PDF, DOC, and DOCX files (supports Dutch and English)
- **Prefilled profiles**: Parsed data automatically fills in profile fields
- **Conditional form logic**: Fields show/hide based on job function and employment type (e.g., BIG registration for dentists, salary vs percentage)
- **Nested records**: Add multiple education and work experience entries
- **Skill filtering**: Skills shown based on selected job function
- **Background processing**: CV parsing runs asynchronously via Active Job
- **Admin panel**: View and manage candidate profiles
- **Private CV storage**: Files stored via Active Storage, not publicly accessible

## Tech Stack

- **Ruby** 3.3.6
- **Rails** 8.1.3
- **PostgreSQL**
- **Tailwind CSS** (via CDN)
- **Stimulus.js** (for interactive form behavior)
- **Devise** (authentication)
- **pdf-reader / docx** (CV parsing)

## Models

- `User` — Devise authentication (roles: candidate, admin, recruiter)
- `CandidateProfile` — Main profile object with all candidate fields
- `CandidateDocument` — CV upload record (linked via Active Storage)
- `Education` — Nested education records
- `WorkExperience` — Nested work experience records
- `Skill` — Master skill list (grouped by job function)
- `CandidateSkill` — Join table (profile <> skill)
- `Language` — Master language list
- `CandidateLanguage` — Join table (profile <> language with level)

## Getting Started

```bash
# Install dependencies
bundle install

# Set up database
bin/rails db:create db:migrate db:seed

# Start the server
bin/rails server
```

## Test Users (seeded)

| Email | Password | Role |
|-------|----------|------|
| admin@example.com | password | Admin |
| recruiter@example.com | password | Recruiter |
| candidate@example.com | password | Candidate |

## Routes

- `/users/sign_in` — Login
- `/onboarding/upload_cv` — Step 1: Upload CV
- `/onboarding/review` — Step 2: Review profile
- `/admin/candidates` — Admin: candidate list
- `/` — Dashboard (post-onboarding)

## Configuration

| Env Variable | Default | Description |
|---|---|---|
| `MAX_CV_SIZE_MB` | `25` | Maximum CV upload size in megabytes |

## Running Tests

```bash
bundle exec rspec
```

## Test Resume Files

Sample CVs for testing parsing are in the project root:

| File | Profile |
|------|---------|
| `test_resume.pdf` / `.doc` / `.docx` | Emma van den Berg — General Dentist |
| `test_hygienist.pdf` / `.doc` / `.docx` | Marieke Jansen — Dental Hygienist |
| `test_orthodontist.pdf` / `.doc` / `.docx` | David Chen — Orthodontist |
| `test_manager.pdf` / `.doc` / `.docx` | Fatima Al-Rashid — Practice Manager |
| `test_experienced_dentist.pdf` / `.doc` / `.docx` | Carlos Mendez — General Dentist (15+ yrs) |

## CV Parser

The `CvParsingService` extracts the following from CVs:

- Name, Email, Phone number
- City, Country
- Languages (with levels)
- Education history
- Work experience history
- Skills (matched against platform skill list)
- BIG number
- Years of experience
- Professional summary

Supported formats: PDF, DOC, DOCX (Dutch and English CVs).

## Conditional Logic

- **Clinical roles** (dentist, hygienist, specialist): Show BIG registration, daily revenue, clinical skills
- **Assistant roles**: Hide BIG registration, show assistant skills
- **Front-office**: Show front-office skills
- **Practice manager**: Show management skills
- **Dental technician**: Show dental tech skills
- **Employed**: Show salary field
- **Self-employed/freelance**: Show percentage field
