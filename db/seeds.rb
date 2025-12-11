puts "=== Seed開始：既存データをリセットします ==="

# 外部キー制約があっても消せるように一時的に無効化
ActiveRecord::Base.connection.disable_referential_integrity do
  # まず主要テーブルを削除
  [Attendance, TimeSlot, Lesson, Student, Faculty].each do |model|
    model.delete_all
  end

  # Absences テーブルが存在する場合だけ、中身を削除（※クラスは触らない）
  if ActiveRecord::Base.connection.table_exists?(:absences)
    ActiveRecord::Base.connection.execute("DELETE FROM absences")
  end
end

puts "-> 既存データ削除完了"


# ----------------------------------------
# 1. ユーザー (Faculty / Student) 作成
# ----------------------------------------

puts "1. Faculty (教員) と Student (学生) を作成します..."

PASSWORD = "password"

faculty = Faculty.create!(
  faculty_number: "F001",
  name: "山田 太郎 (管理者)",
  password: PASSWORD,
  password_confirmation: PASSWORD
)
puts "  -> 教員: #{faculty.name} (ID: #{faculty.faculty_number}) 作成完了"

students_data = [
  { student_number: "2023001", name: "佐藤 葵",   birth_date: Date.new(2004, 5, 10), address: "東京都", emergency_contact: "090-1111-2222" },
  { student_number: "2023002", name: "田中 健太", birth_date: Date.new(2003, 8, 20), address: "大阪府", emergency_contact: "090-3333-4444" },
  { student_number: "2023003", name: "鈴木 花子", birth_date: Date.new(2004, 1, 15), address: "福岡県", emergency_contact: "090-5555-6666" }
]

students = students_data.map do |data|
  Student.create!(
    student_number:        data[:student_number],
    name:                  data[:name],
    birth_date:            data[:birth_date],
    address:               data[:address],
    emergency_contact:     data[:emergency_contact],
    password:              PASSWORD,
    password_confirmation: PASSWORD
  )
end
puts "  -> 学生3名 作成完了（パスワード: #{PASSWORD}）"

# ----------------------------------------
# 2. 授業 (Lesson) と コマ時間 (TimeSlot) 作成
# ----------------------------------------

puts "2. Lesson (授業) と TimeSlot (コマ時間) を作成します..."

today = Date.current

lesson1 = Lesson.new(
  lesson_name: "オブジェクト指向プログラミング",
  faculty: faculty
)
lesson1.detail = "Ruby on Rails を用いた実践的な Web 開発。" if lesson1.respond_to?(:detail=)
lesson1.save!

lesson2 = Lesson.new(
  lesson_name: "データベース概論",
  faculty: faculty
)
lesson2.detail = "リレーショナル DB と SQL を学ぶ。" if lesson2.respond_to?(:detail=)
lesson2.save!

puts "  -> 授業2科目 作成完了"

# 仕様通りの 1〜5コマ
# 1コマ  9:00〜10:00（10分休憩）
# 2コマ 10:10〜11:10（10分休憩）
# 3コマ 11:20〜12:20（10分休憩）
# 昼休憩 12:20〜13:20
# 4コマ 13:20〜14:20（10分）
# 5コマ 14:30〜15:30（ある学生のみ）

time_slots_data = [
  {
    name: "1コマ",
    lesson: lesson1,
    start_time: "09:00:00",
    end_time: "10:00:00",
    attendance_start_time: "08:50:00",
    break_time: "00:10:00"
  },
  {
    name: "2コマ",
    lesson: lesson1,
    start_time: "10:10:00",
    end_time: "11:10:00",
    attendance_start_time: "10:00:00",
    break_time: "00:10:00"
  },
  {
    name: "3コマ",
    lesson: lesson1,
    start_time: "11:20:00",
    end_time: "12:20:00",
    attendance_start_time: "11:10:00",
    break_time: "00:10:00"
  },
  {
    name: "4コマ",
    lesson: lesson2,
    start_time: "13:20:00",
    end_time: "14:20:00",
    attendance_start_time: "13:10:00",
    break_time: "00:10:00"
  },
  {
    name: "5コマ",
    lesson: lesson2,
    start_time: "14:30:00",
    end_time: "15:30:00",
    attendance_start_time: "14:20:00",
    break_time: "00:00:00"
  }
]

time_slots = time_slots_data.map do |data|
  ts = TimeSlot.create!(
    lesson:                data[:lesson],
    date:                  today,
    start_time:            Time.zone.parse(data[:start_time]),
    end_time:              Time.zone.parse(data[:end_time]),
    attendance_start_time: Time.zone.parse(data[:attendance_start_time]),
    break_time:            Time.zone.parse(data[:break_time])
  )
  puts "  -> #{data[:name]}: #{ts.start_time.strftime('%H:%M')}〜#{ts.end_time.strftime('%H:%M')} 作成"
  ts
end

puts "  -> コマ時間 #{time_slots.size}件 作成完了"

# ----------------------------------------
# 3. 出席記録 (Attendance) ダミーデータ
# ----------------------------------------

puts "3. Attendance (出席記録) のダミーデータを作成します..."

time_slot1 = time_slots.first # 1コマ目

student1 = students[0] # 佐藤 葵
student2 = students[1] # 田中 健太

# 1コマ目：出席
Attendance.create!(
  student:        student1,
  time_slot:      time_slot1,
  status:         "present",
  registered_at:  Time.zone.local(today.year, today.month, today.day, 8, 55, 0), # 8:55
  late_reason:    nil,
  admin_approval: true
)

# 1コマ目：遅刻（承認待ち）
Attendance.create!(
  student:        student2,
  time_slot:      time_slot1,
  status:         "late",
  registered_at:  Time.zone.local(today.year, today.month, today.day, 9, 5, 0), # 9:05
  late_reason:    "電車遅延のため",
  admin_approval: false
)

puts "  -> 出席1名, 遅刻1名 作成完了"

puts "=== Seed完了！ ==="
puts "教員ログインID: F001 / パスワード: #{PASSWORD}"
puts "学生ログイン例: 2023001 / パスワード: #{PASSWORD}"
