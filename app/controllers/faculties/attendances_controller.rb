# app/controllers/faculties/attendances_controller.rb
class Faculties::AttendancesController < ApplicationController
  before_action :authenticate_faculty!

  def index
    Attendance.mark_auto_absent_for_past_slots!
  
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
  
    @attendances = @attendances.where(time_slots: { date: target_date })
  
    if search_params[:lesson_name].present?
      @attendances = @attendances.where(lessons: { lesson_name: search_params[:lesson_name] })
    end
  
    # 🔽 ここ追加：「新しい順」にする
    # registered_at があればそれ優先、なければ created_at でOK
    @attendances = @attendances.order(created_at: :desc)
    # もっと厳密にやるなら:
    # @attendances = @attendances.order('attendances.registered_at DESC NULLS LAST, attendances.created_at DESC')
  
    @json_response = {
      counts: @attendances.group(:status).count,
      details: @attendances.map do |att|
        {
          id:             att.id,
          student_number: att.student.student_number,
          name:           att.student.name,
          registered_at:  att.registered_at&.strftime('%H:%M') || '---',
          status:         att.status,
          status_label:   att.status_label,
          late_reason:    att.late_reason,
          lesson_name:    att.time_slot.lesson.lesson_name,
          admin_approval: att.admin_approval
        }
      end
    }
  
    render :index
  end
  

  def update
    @attendance = Attendance.find(params[:id])

    if params[:admin_approval].present?
      # ✅ 遅刻の承認/却下
      @attendance.update!(admin_approval: params[:admin_approval])
      message = "承認ステータスを更新しました。"

    elsif params[:status].present?
      case params[:status]
      when 'early_leave'
        # ✅ 早退に変更
        @attendance.update!(
          status: 'early_leave',
          admin_approval: true
        )
        message = "状態を『早退』に変更しました。"

      when 'absent'
        # ✅ 欠席に変更（先生操作）
        @attendance.update!(
          status: 'absent',
          registered_at: Time.current,
          late_reason: '教員により欠席へ変更',
          admin_approval: true
        )
        message = "状態を『欠席』に変更しました。"

      when 'present'
        # ✅ 出席扱いに変更（押し忘れ救済）
        @attendance.update!(
          status: 'present',
          registered_at: Time.current,
          late_reason: nil,
          admin_approval: true
        )
        message = "状態を『出席』に変更しました。"

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
    params.permit(:lesson_name, :date)
  end
end
