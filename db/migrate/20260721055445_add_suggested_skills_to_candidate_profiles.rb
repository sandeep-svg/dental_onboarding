class AddSuggestedSkillsToCandidateProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :candidate_profiles, :suggested_skills, :text
  end
end
