# frozen_string_literal: true
class AddUniqueIndexesToJoinTables < ActiveRecord::Migration[8.1]
  def change
    add_index :skills, [:name, :job_function_id], unique: true, name: "index_skills_on_name_and_job_function_id"
    add_index :candidate_skills, [:candidate_profile_id, :skill_id], unique: true, name: "index_candidate_skills_on_profile_and_skill"
    add_index :candidate_languages, [:candidate_profile_id, :language_id], unique: true, name: "index_candidate_languages_on_profile_and_language"
    add_index :languages, :name, unique: true, name: "index_languages_on_name"
  end
end