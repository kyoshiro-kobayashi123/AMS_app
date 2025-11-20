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