class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.text :name
      t.text :abbreviation

      t.timestamps null: false
    end
  end
end
