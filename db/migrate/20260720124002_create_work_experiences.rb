# frozen_string_literal: true
class CreateWorkExperiences < ActiveRecord::Migration[8.1]
  def change
    create_table :work_experiences do |t|
      t.references :candidate_profile, null: false, foreign_key: true
      t.string :job_title
      t.string :company_name
      t.text :responsibilities
      t.date :start_date
      t.date :end_date
      t.boolean :current_job

      t.timestamps
    end
  end
end
