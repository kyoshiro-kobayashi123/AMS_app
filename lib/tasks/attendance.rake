namespace :attendance do
  desc "コマ開始30分後、出席未登録の学生を自動で欠席 (absent) 扱いにする"
  task auto_absent: :environment do
    puts "--- 自動欠席処理を開始 ---"
    
    # 処理実行日
    target_date = Date.current
    
    # 1. 処理対象の TimeSlot を取得する
    #    - 今日が対象日
    #    - コマ開始から30分後が現在時刻より過去であること
    #    - 既に欠席処理済みでないこと (ここではシンプルに現在時刻で判定)
    
    # Time.current を基準として、該当するコマを取得
    TimeSlot.all.each do |time_slot|
      # DBのTime型を、今日の日付と結合して正確な時刻オブジェクトにする
      start_time = Time.zone.local(target_date.year, target_date.month, target_date.day, time_slot.start_time.hour, time_slot.start_time.min)
      absent_deadline = start_time + 30.minutes # 欠席締め切り時刻
      
      # 2. 欠席締め切り時刻が過ぎているかチェック
      if absent_deadline <= Time.current
        puts "  [#{time_slot.lesson.lesson_name} #{time_slot.start_time.strftime('%H:%M')}開始] の処理中..."
        
        # 3. 欠席とすべき学生を特定 (ここでは全学生から、Attendanceがある学生を除く)
        #    ※実際はLessonとStudentを紐づけるテーブル(Enrollment等)があるべきですが、
        #      今回は簡易的に全学生からAttendanceがある学生を除外します。
        
        attended_student_ids = Attendance.where(time_slot: time_slot, created_at: target_date.all_day).pluck(:student_id)
        
        # 4. 未登録の学生に対して Attendance レコードを作成
        Student.where.not(id: attended_student_ids).each do |student|
          
          # 欠席が確定した時刻を registered_at に挿入
          # 以前は nil でエラーになっていた箇所です
          determined_time = Time.current 

          Attendance.find_or_create_by!(student: student, time_slot: time_slot, registered_at: determined_time) do |a|
            a.status = 'absent'
            a.admin_approval = true # 自動欠席なので承認済み
            a.created_at = determined_time
            a.updated_at = determined_time
          end
          puts "    -> 学生ID:#{student.student_number} (#{student.name}) を欠席に設定 (判定時刻: #{determined_time.strftime('%H:%M:%S')})"
        end
      end
    end
    
    puts "--- 自動欠席処理を完了 ---"
  end
end