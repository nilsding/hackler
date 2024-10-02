# frozen_string_literal: true

class CreateHacklerJobs < ActiveRecord::Migration[7.2]
  def change
    create_table :hackler_jobs do |t|
      t.text :data

      t.timestamps
    end
  end
end
