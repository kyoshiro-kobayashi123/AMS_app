class CreateLessons < ActiveRecord::Migration[8.0]
  def change
    create_table :lessons do |t|
      t.string :lesson_name, null:false
      t.references :faculty, null: false, foreign_key: true

      t.timestamps
    end
  end
end
