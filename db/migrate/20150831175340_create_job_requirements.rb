class CreateJobRequirements < ActiveRecord::Migration
  def change
    create_table :job_requirements do |t|
      t.belongs_to :item
      t.belongs_to :job
      t.integer :level
      t.timestamps null: false
    end
  end
end
