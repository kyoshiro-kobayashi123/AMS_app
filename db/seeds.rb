# ----------------------------------------
# 1. ユーザー (Faculty/Student) の作成
# ----------------------------------------

puts "1. Faculty (管理者) と Student (学生) の作成を開始..."

# パスワードは仮で 'password' に設定します
PASSWORD = 'password'

# 教員/管理者 (Faculty)
faculty = Faculty.find_or_create_by!(faculty_number: 'F001') do |f|
  f.name = '山田 太郎 (管理者)'
  f.password = PASSWORD
  f.password_confirmation = PASSWORD
end
puts "  -> 管理者: #{faculty.name} (ID: #{faculty.faculty_number}) 作成完了"

# 学生 (Student)
students_data = [
  { student_number: '2023001', name: '佐藤 葵', birth_date: Date.new(2004, 5, 10), address: '東京都', emergency_contact: '090-1111-2222' },
  { student_number: '2023002', name: '田中 健太', birth_date: Date.new(2003, 8, 20), address: '大阪府', emergency_contact: '090-3333-4444' },
  { student_number: '2023003', name: '鈴木 花子', birth_date: Date.new(2004, 1, 15), address: '福岡県', emergency_contact: '090-5555-6666' }
]

students_data.each do |data|
  Student.find_or_create_by!(student_number: data[:student_number]) do |s|
    s.name = data[:name]
    s.birth_date = data[:birth_date]
    s.address = data[:address]
    s.emergency_contact = data[:emergency_contact]
    s.password = PASSWORD
    s.password_confirmation = PASSWORD
  end
end
puts "  -> 学生3名 作成完了 (パスワード: #{PASSWORD})"

# ----------------------------------------
# 2. 授業 (Lesson) と コマ時間 (TimeSlot) の作成
# ----------------------------------------

puts "2. Lesson (授業) と TimeSlot (コマ時間) の作成を開始..."

# 授業 (Lesson)
lesson1 = Lesson.find_or_create_by!(lesson_name: 'オブジェクト指向プログラミング') do |l|
  l.faculty = faculty
  # detailカラムが存在する場合のみ設定
  l.detail = 'Ruby on Railsを用いた実践的なWeb開発技術を学ぶ。' if l.respond_to?(:detail=)
end

lesson2 = Lesson.find_or_create_by!(lesson_name: 'データベース概論') do |l|
  l.faculty = faculty
  l.detail = 'リレーショナルデータベースの設計とSQLを学ぶ。' if l.respond_to?(:detail=)
end
puts "  -> 授業2科目 作成完了"

# コマ時間 (TimeSlot) の定義
# 今日の日付を基準にする
today = Date.current

time_slots_data = [
   { 
    lesson: lesson1, # オブジェクト指向プログラミング
    date: today,
    start_time: '09:00', # 1コマ目に合わせる
    end_time: '10:00', 
    break_time: '00:00', 
    attendance_start_time: '08:50' 
  },
  { 
    lesson: lesson1, # オブジェクト指向プログラミング (2回目)
    date: today,
    start_time: '10:10', # 2コマ目に合わせる (変更点)
    end_time: '11:10',   # (変更点)
    break_time: '00:00', 
    attendance_start_time: '10:00' 
  },
  { 
    lesson: lesson2, # データベース概論
    date: today,
    start_time: '13:20', # 4コマ目に合わせる (変更点)
    end_time: '14:20',   # (変更点)
    break_time: '00:00', 
    attendance_start_time: '13:10' 
  }
]

time_slots_data.each do |data|
  TimeSlot.find_or_create_by!(
    lesson: data[:lesson], 
    date: data[:date],
    start_time: data[:start_time]
  ) do |ts|
    ts.end_time = data[:end_time]
    ts.break_time = data[:break_time]
    ts.attendance_start_time = data[:attendance_start_time]
  end
end
puts "  -> コマ時間3件 作成完了"

# ----------------------------------------
# 3. 出席記録 (Attendance) のダミーデータ作成
# ----------------------------------------

puts "3. Attendance (出席記録) のダミーデータを作成..."

# 1コマ目のTimeSlotを取得
time_slot1 = TimeSlot.find_by(date: today, start_time: '09:30:00')

if time_slot1
  # 学生1 (佐藤): 通常出席 (9:25 登録)
  student1 = Student.find_by(student_number: '2023001')
  Attendance.find_or_create_by!(
    student: student1, 
    time_slot: time_slot1
  ) do |a|
    a.status = 'present'
    a.registered_at = today.beginning_of_day + 9.hours + 25.minutes
    a.admin_approval = true
  end

  # 学生2 (田中): 遅刻 (9:40 登録)
  student2 = Student.find_by(student_number: '2023002')
  Attendance.find_or_create_by!(
    student: student2, 
    time_slot: time_slot1
  ) do |a|
    a.status = 'late'
    a.registered_at = today.beginning_of_day + 9.hours + 40.minutes
    a.late_reason = '電車遅延のため'
    a.admin_approval = false
  end

  puts "  -> ダミー出席データ (出席1名, 遅刻1名) 作成完了"
else
  puts "  -> TimeSlotが見つかりませんでした"
end

puts "Seedデータの投入が完了しました。"