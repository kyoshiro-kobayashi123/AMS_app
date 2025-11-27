class Faculties::AttendancesController < ApplicationController
  # 教員（Faculty）のみアクセス可能にする
  before_action :authenticate_faculty! 
  
  # 検索と一覧表示、集計を行うアクション
  def index
    search_params = attendance_search_params

    @attendances = Attendance
      .joins(time_slot: :lesson)
      .includes(:student, :time_slot)

    target_date =
      if search_params[:date].present?
        Date.parse(search_params[:date])
      else
        Date.current
      end

    # ✅ 出欠の「日付」は time_slots.date で絞る
    @attendances = @attendances.where(time_slots: { date: target_date })

    if search_params[:lesson_name].present?
      @attendances = @attendances.where(lessons: { lesson_name: search_params[:lesson_name] })
    end

    if search_params[:time_slot_id].present?
      @attendances = @attendances.where(time_slot_id: search_params[:time_slot_id])
    end

    @json_response = {
      counts: @attendances.group(:status).count,
      details: @attendances.map do |att|
        {
          id: att.id,
          student_number: att.student.student_number,
          name: att.student.name,
          registered_at: att.registered_at&.strftime('%H:%M') || '---',
          status: att.status,
          late_reason: att.late_reason,
          lesson_name: att.time_slot.lesson.lesson_name,
          admin_approval: att.admin_approval
        }
      end
    }

    render :index
  end
  
  
  

  # 状態変更/承認を行うアクション
  def update
    @attendance = Attendance.find(params[:id])

    if params[:admin_approval].present?
      # 遅刻申請の承認/却下など
      @attendance.update!(admin_approval: params[:admin_approval])
      message = "承認ステータスを更新しました。"

    elsif params[:status].present?
      case params[:status]
      when 'early_leave'
        # ✅ 早退
        @attendance.update!(
          status: 'early_leave',
          admin_approval: true
        )
        message = "状態を 早退 に変更しました。"

      when 'absent'
        # ✅ 欠席（先生が手動変更）
        @attendance.update!(
          status: 'absent',
          registered_at: Time.current, # いつ欠席にしたかを残したいなら
          late_reason: nil,
          admin_approval: true
        )
        message = "状態を 欠席 に変更しました。"

      else
        return redirect_to faculties_attendances_path, alert: '不正なステータスです。'
      end

    else
      return redirect_to faculties_attendances_path, alert: '更新パラメータが不足しています'
    end

    redirect_to faculties_attendances_path, notice: message

  rescue ActiveRecord::RecordNotFound
    redirect_to faculties_attendances_path, alert: '対象の出席記録が見つかりません'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to faculties_attendances_path, alert: "更新に失敗しました: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def attendance_search_params
    params.permit(:lesson_name, :date, :time_slot_id)
  end
end