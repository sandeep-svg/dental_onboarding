# frozen_string_literal: true
class CreateLanguages < ActiveRecord::Migration[8.1]
  def change
    create_table :languages do |t|
      t.string :name

      t.timestamps
    end
  end
end
