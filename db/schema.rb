# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_13_050723) do
  create_table "absences", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "time_slot_id", null: false
    t.string "kind"
    t.string "reason"
    t.text "detail"
    t.date "deadline"
    t.boolean "admin_approval"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_absences_on_student_id"
    t.index ["time_slot_id"], name: "index_absences_on_time_slot_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "student_id", null: false
    t.integer "time_slot_id", null: false
    t.string "status", null: false
    t.datetime "registered_at", null: false
    t.string "late_reason"
    t.boolean "admin_approval", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_attendances_on_student_id"
    t.index ["time_slot_id"], name: "index_attendances_on_time_slot_id"
  end

  create_table "faculties", force: :cascade do |t|
    t.string "faculty_number", limit: 20, null: false
    t.string "name", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.index ["email"], name: "index_faculties_on_email", unique: true
    t.index ["faculty_number"], name: "index_faculties_on_faculty_number", unique: true
    t.index ["reset_password_token"], name: "index_faculties_on_reset_password_token", unique: true
  end

  create_table "lessons", force: :cascade do |t|
    t.string "lesson_name", null: false
    t.integer "faculty_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "detail"
    t.index ["faculty_id"], name: "index_lessons_on_faculty_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "student_number", limit: 20, null: false
    t.string "name", limit: 100, null: false
    t.date "birth_date"
    t.string "address"
    t.string "emergency_contact", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "encrypted_password", default: "", null: false
    t.index ["reset_password_token"], name: "index_students_on_reset_password_token", unique: true
    t.index ["student_number"], name: "index_students_on_student_number", unique: true
  end

  create_table "time_slots", force: :cascade do |t|
    t.integer "lesson_id", null: false
    t.date "date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.time "break_time", null: false
    t.time "attendance_start_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_time_slots_on_lesson_id"
  end

  add_foreign_key "absences", "students"
  add_foreign_key "absences", "time_slots"
  add_foreign_key "attendances", "students"
  add_foreign_key "attendances", "time_slots"
  add_foreign_key "lessons", "faculties"
  add_foreign_key "time_slots", "lessons"
end
