class SchedulesController < ApplicationController
  before_action :authenticate_any!
  def index
    # Use the start_date from params if it exists, otherwise use today's date.
    @date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today

    # Get the beginning and end of the week for the given date.
    start_of_week = @date.beginning_of_week
    end_of_week = @date.end_of_week

    # Create an array of days for the week.
    @week_days = (start_of_week..end_of_week).to_a

    # Fetch schedules for the displayed week, assuming a Schedule model exists.
    @time_slots = TimeSlot.includes(:lesson).where(date: start_of_week..end_of_week)
    # ビューで使いやすくするために、データをハッシュ形式に変換
    # キー: [日付, "開始時間-終了時間"], 値: TimeSlotオブジェクト
    # 例: {[Wed, 20 Nov 2025, "09:00-10:00"] => time_slot_instance}
    @time_slots_map = @time_slots.index_by { |ts| [ts.date, "#{ts.start_time.strftime('%H:%M')}-#{ts.end_time.strftime('%H:%M')}"] }

    # 縦軸: 表示したい「時限（コマ）」の定義
    # 実際の運用に合わせて時間は調整してください
    @periods = [
      { name: "1コマ", time: "09:00-10:00", start_time: "09:00" },
      { name: "2コマ", time: "10:10-11:10", start_time: "10:10" },
      { name: "3コマ", time: "11:20-12:20", start_time: "11:20" },
      { name: "昼休み", time: "12:20-1320", start_time: "" },
      { name: "4コマ", time: "13:20-14:20", start_time: "13:20" },
      { name: "5コマ", time: "14:30-15:30", start_time: "14:30" },
      # 必要に応じて4コマ、5コマと追加してください
    ]
  end
  def authenticate_any!
    # 生徒も教員もログインしていなければ、生徒のログイン画面へ飛ばす
    unless student_signed_in? || faculty_signed_in?
      redirect_to new_student_session_path, alert: "ログインしてください"
    end
  end
end