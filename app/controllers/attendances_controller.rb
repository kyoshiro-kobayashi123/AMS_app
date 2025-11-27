class AttendancesController < ApplicationController
  before_action :authenticate_student! 

  def create
    time_slot = TimeSlot.find(attendance_params[:time_slot_id])
    registration_time = Time.current

    # ✅ このコマの日付と今日が一致しているか
    if registration_time.to_date != time_slot.date
      redirect_to new_attendance_path,
                  alert: "このコマの出席登録は #{time_slot.date.strftime('%Y/%m/%d')} のみ可能です。"
      return
    end

    # ✅ 二重登録チェック（そのコマに対して一度だけ）
    if current_student.attendances.exists?(time_slot: time_slot)
      redirect_to new_attendance_path, alert: "このコマはすでに出席登録済みです。"
      return
    end

    # ✅ ステータス判定
    status, late_reason, admin_approval =
      determine_status(time_slot, registration_time, attendance_params[:late_reason])

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
      redirect_to new_attendance_path,
                  notice: "#{status == 'late' ? '遅刻申請' : '出席'}を登録しました。"
    else
      redirect_to new_attendance_path, alert: "登録に失敗しました。"
    end
  end

  private

  # 🔹フォームのパラメータ許可
  def attendance_params
    params.permit(:time_slot_id, :late_reason)
  end

  # 🔹出席ステータス判定ロジック
  def determine_status(time_slot, registration_time, reason)
    date = time_slot.date

    # 授業開始時刻（そのコマの「日付＋時刻」で Time を作る）
    lesson_start = Time.zone.local(
      date.year, date.month, date.day,
      time_slot.start_time.hour, time_slot.start_time.min, time_slot.start_time.sec
    )

    # 出席受付開始時刻（attendance_start_time を使う）
    attendance_start = Time.zone.local(
      date.year, date.month, date.day,
      time_slot.attendance_start_time.hour,
      time_slot.attendance_start_time.min,
      time_slot.attendance_start_time.sec
    )

    # 遅刻締め切り（授業開始から20分後）
    late_deadline = lesson_start + 20.minutes

    ################
    # テスト用コード #
    ################
    # late_deadline = lesson_start + 5.hours

    if registration_time < attendance_start
      # 受付開始前
      ['error', "まだ登録時間になっていません。（登録可能時間：#{attendance_start.strftime('%H:%M')}〜）", false]

    elsif registration_time <= lesson_start
      # 受付開始〜授業開始 → 通常出席
      ['present', nil, true]

    elsif registration_time <= late_deadline
      # 授業開始〜締切 → 遅刻（理由必須）
      if reason.blank?
        ['error', '遅刻登録の場合は理由の入力が必要です。', false]
      else
        ['late', reason, false]
      end

    else
      # 締切以降
      ['error', "登録時間を過ぎています。（遅刻締め切り：#{late_deadline.strftime('%H:%M')}）", false]
    end
  end
end
