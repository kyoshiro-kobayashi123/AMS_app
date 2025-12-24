class SchedulesController < ApplicationController
  before_action :authenticate_any!
  before_action :authenticate_faculty!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_time_slot, only: [:edit, :update, :destroy]

  def index
    # Use the start_date from params if it exists, otherwise use today's date.
    @date = params[:start_date] ? Date.parse(params[:start_date]) : Date.today

    # Get the beginning and end of the week for the given date.
    start_of_week = @date.beginning_of_week
    end_of_week = @date.end_of_week

    # Create an array of days for the week.
    @week_days = (start_of_week..end_of_week).to_a

    # Fetch schedules for the displayed week, assuming a Schedule model exists.
    @time_slots = TimeSlot.includes(lesson: :faculty).where(date: start_of_week..end_of_week)
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
      { name: "昼休み", time: "12:20-13:20", start_time: "12:20" },
      { name: "4コマ", time: "13:20-14:20", start_time: "13:20" },
      { name: "5コマ", time: "14:30-15:30", start_time: "14:30" },
      { name: "6コマ", time: "15:40-16:40", start_time: "15:40" }
      # 必要に応じて4コマ、5コマと追加してください
    ]
  end

  def new
    @time_slot = TimeSlot.new
    # パラメータから日付と時間を受け取る
    @time_slot.date = params[:date] if params[:date]
    if params[:time]
      # "09:30-11:10" のような形式から start_time と end_time を設定
      times = params[:time].split('-')
      @time_slot.start_time = times[0]
      @time_slot.end_time = times[1]
    end
    
    @faculties = Faculty.all
    @selected_faculty_id = params[:selected_faculty_id]
    @classrooms = Classroom.all
    
    # 選択された教員の授業を取得
    if @selected_faculty_id.present?
      @lessons = Faculty.find(@selected_faculty_id).lessons
    else
      @lessons = Lesson.all  # または空の配列: []
    end
  end

  def create
    @time_slot = TimeSlot.new(time_slot_params)
    @time_slot.break_time = Time.parse("00:00")
    @time_slot.attendance_start_time ||= @time_slot.start_time
    
    if @time_slot.save
      redirect_to schedules_path, notice: 'スケジュールを登録しました。'
    else
      @faculties = Faculty.all
      @classrooms = Classroom.all
      
    # 選択された授業から教員IDを取得
    if @time_slot.lesson_id.present?
      lesson = Lesson.find_by(id: @time_slot.lesson_id)
      @selected_faculty_id = lesson.faculty_id if lesson
    else
      @selected_faculty_id = params[:selected_faculty_id]
    end
    
    if @selected_faculty_id.present?
      faculty = Faculty.find(@selected_faculty_id)
      @lessons = faculty.lessons
    else
      @lessons = Lesson.all
    end

    render :new, status: :unprocessable_entity
    end
  end

  def edit
    @faculties = Faculty.all
    # lesson経由でfaculty_idを取得
    @selected_faculty_id = params[:selected_faculty_id] || @time_slot.lesson&.faculty_id
    @lessons = @selected_faculty_id ? Faculty.find(@selected_faculty_id).lessons : current_faculty.lessons
    @classrooms = Classroom.all # 教室一覧を取得
  end

  def update
    @faculties = Faculty.all
    @selected_faculty_id = params[:selected_faculty_id] || @time_slot.lesson&.    faculty_id
    @lessons = @selected_faculty_id ? Faculty.find(@selected_faculty_id).lessons :     current_faculty.lessons
    
    if @time_slot.update(time_slot_params)
      redirect_to schedules_path, notice: 'スケジュールを更新しました。'
    else
    @faculties = Faculty.all
    @selected_faculty_id = params[:selected_faculty_id]
    @lessons = Lesson.where(faculty_id: @selected_faculty_id)
    @classrooms = Classroom.all # エラー時も教室一覧を準備
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_slot.destroy
    redirect_to schedules_path, notice: 'スケジュールを削除しました。'
  end

  private

  def authenticate_any!
    # 生徒も教員もログインしていなければ、生徒のログイン画面へ飛ばす
    unless student_signed_in? || faculty_signed_in?
      puts "ログインしてません"
      redirect_to new_student_session_path, alert: "ログインしてください"
    end
  end

  def authenticate_faculty!
    unless faculty_signed_in?
      redirect_to schedules_path, alert: "教員としてログインしてください。"
    end
  end

  def set_time_slot
    @time_slot = TimeSlot.find(params[:id])
    # 自分の授業以外は編集不可にする場合（オプション）
    #if @time_slot.lesson && @time_slot.lesson.faculty_id != current_faculty.id
    #  redirect_to schedules_path, alert: '権限がありません。'
  end

  def time_slot_params
    params.require(:time_slot).permit(:date, :start_time, :end_time, :lesson_id, :classroom_id)
  end
end