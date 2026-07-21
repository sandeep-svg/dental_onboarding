# frozen_string_literal: true
class CreateCandidateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :candidate_documents do |t|
      t.references :candidate_profile, null: false, foreign_key: true
      t.string :original_filename
      t.string :content_type
      t.integer :file_size
      t.datetime :parsed_at
      t.string :parsing_status

      t.timestamps
    end
  end
end
