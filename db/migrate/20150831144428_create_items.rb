class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.text :name

      t.timestamps null: false
    end
  end
end
