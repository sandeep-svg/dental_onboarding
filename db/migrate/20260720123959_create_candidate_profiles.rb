# frozen_string_literal: true
class CreateCandidateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number
      t.string :city
      t.string :country
      t.integer :desired_job_function_id
      t.text :preferred_regions
      t.integer :max_travel_time
      t.text :transport_type
      t.string :search_status
      t.text :reason_for_looking
      t.text :desired_employment_type
      t.decimal :desired_gross_salary
      t.integer :desired_percentage
      t.decimal :average_daily_revenue
      t.string :big_registration_status
      t.string :big_number
      t.integer :years_of_experience
      t.text :available_working_days
      t.date :available_from
      t.string :notice_period
      t.text :motivation
      t.text :internal_notes
      t.text :professional_summary
      t.boolean :consent_accepted
      t.boolean :onboarding_completed
      t.string :parsing_status

      t.timestamps
    end
  end
end
