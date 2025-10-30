class CreateTimeSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :time_slots do |t|
      t.references :lesson, null: false, foreign_key: true
      t.date :date, null:false
      t.time :start_time, null:false
      t.time :end_time, null:false
      t.time :break_time, null:false
      t.time :attendance_start_time, null:false

      t.timestamps
    end
  end
end
