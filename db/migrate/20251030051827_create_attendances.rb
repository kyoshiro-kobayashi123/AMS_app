class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :student, null: false, foreign_key: true
      t.references :time_slot, null: false, foreign_key: true
      t.string :status, null:false
      t.datetime :registered_at, null:false
      t.string :late_reason
      t.boolean :admin_approval, null:false

      t.timestamps
    end
  end
end
