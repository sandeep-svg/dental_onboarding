# frozen_string_literal: true
class CreateSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :skills do |t|
      t.string :name
      t.string :group_name
      t.integer :job_function_id

      t.timestamps
    end
  end
end
