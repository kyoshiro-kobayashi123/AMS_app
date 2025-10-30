class CreateAbsences < ActiveRecord::Migration[8.0]
  def change
    create_table :absences do |t|
      t.references :student, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.string :kind
      t.string :reason
      t.text :detail
      t.date :deadline
      t.boolean :admin_approval

      t.timestamps
    end
  end
end
