class AttendancesController < ApplicationController
  # ログインしている学生のみが実行可能と想定
  before_action :authenticate_student! 

  def create
    # パラメータから time_slot_id を取得
    time_slot = TimeSlot.find(attendance_params[:time_slot_id])
    registration_time = Time.current
    
    # 登録済みかチェック（二重登録防止）
    if current_student.attendances.exists?(time_slot: time_slot, date: Date.current)
      redirect_to root_path, alert: "すでに出席登録済みです。"
      return
    end

    status, late_reason, admin_approval = determine_status(time_slot, registration_time, attendance_params[:late_reason])
    
    if status == 'error'
      redirect_to root_path, alert: late_reason # エラーメッセージ
      return
    end

    attendance = current_student.attendances.build(
      time_slot: time_slot,
      status: status,
      registered_at: registration_time,
      late_reason: late_reason,
      admin_approval: admin_approval
    )

    if attendance.save
      redirect_to root_path, notice: "#{status == 'late' ? '遅刻申請' : '出席'}を登録しました。"
    else
      redirect_to root_path, alert: "登録に失敗しました。"
    end
  end

  private
  
  def attendance_params
    # フォームから time_slot_id と 遅刻理由 (late_reason) を受け取る
    params.require(:attendance).permit(:time_slot_id, :late_reason)
  end

  # statusを決定するコアロジック
  def determine_status(time_slot, registration_time, reason)
    today = Date.current
    
    # DBのTime型を、今日の日付と結合して正確な時刻オブジェクトにする
    start_time = Time.zone.local(today.year, today.month, today.day, time_slot.start_time.hour, time_slot.start_time.min)
    
    # 💡 基準時刻の再計算
    # 通常出席開始 = コマ開始 10分前
    ten_minutes_before = start_time - 10.minutes 
    
    # 遅刻登録締め切り = コマ開始 20分後
    late_deadline = start_time + 20.minutes 
    
    
    if registration_time.between?(ten_minutes_before, start_time)
      # コマ開始10分前 (例: 9:20) ～ コマ開始 (例: 9:30) -> 通常出席
      return ['present', nil, true] # 理由なし, 自動承認
    
    elsif registration_time.between?(start_time + 1.second, late_deadline)
      # コマ開始 (例: 9:30) ～ コマ開始20分後 (例: 9:50) -> 遅刻
      if reason.blank?
        return ['error', '遅刻登録の場合は理由の入力が必要です。', false]
      end
      return ['late', reason, false] # 理由あり, 管理者承認待ち
      
    else
      # その他の時間帯 -> 登録不可
      if registration_time < ten_minutes_before
        return ['error', 'まだ登録時間になっていません。（登録可能時間：コマ開始10分前）', false]
      else # registration_time > late_deadline
        # コマ開始30分後で自動欠席とする処理は、別途バッチ処理で実装するため、ここでは登録不可のエラーとする
        return ['error', "登録時間を過ぎています。（遅刻締め切り：#{late_deadline.strftime('%H:%M')}）", false]
      end
    end
  end
end