# app/controllers/attendances_controller.rb
class AttendancesController < ApplicationController
  before_action :authenticate_student! 

  def create
    time_slot = TimeSlot.find(attendance_params[:time_slot_id])
    registration_time = Time.current

    # 二重登録チェック
    if current_student.attendances.exists?(time_slot: time_slot, created_at: Date.current.all_day)
      redirect_to new_attendance_path, alert: "すでに出席登録済みです。"
      return
    end

    status, late_reason, admin_approval = determine_status(time_slot, registration_time, attendance_params[:late_reason])

    if status == 'error'
      redirect_to new_attendance_path, alert: late_reason
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
      redirect_to new_attendance_path, notice: "#{status == 'late' ? '遅刻申請' : '出席'}を登録しました。"
    else
      redirect_to new_attendance_path, alert: "登録に失敗しました。"
    end
  end

  private

  def attendance_params
    params.permit(:time_slot_id, :late_reason)
  end

  # 出席ステータス判定
  # 出席ステータス判定
  def determine_status(time_slot, registration_time, reason)
    today = Date.current
  
    # TimeSlot#start_time は time 型。JSTとして扱いたいので hour/min/sec を直接使用
    start_time = Time.zone.parse("#{today} #{time_slot.start_time.strftime('%H:%M:%S')}")
  
    ten_minutes_before = start_time - 10.minutes
    late_deadline = start_time + 20.minutes
  
    if registration_time.between?(ten_minutes_before, start_time)
      ['present', nil, true]
    elsif registration_time.between?(start_time + 1.second, late_deadline)
      if reason.blank?
        ['error', '遅刻登録の場合は理由の入力が必要です。', false]
      else
        ['late', reason, false]
      end
    else
      if registration_time < ten_minutes_before
        ['error', "まだ登録時間になっていません。（登録可能時間：#{ten_minutes_before.strftime('%H:%M')}）", false]
      else
        ['error', "登録時間を過ぎています。（遅刻締め切り：#{late_deadline.strftime('%H:%M')}）", false]
      end
    end
  end
  

end
