class Attendance < ApplicationRecord
  belongs_to :student
  belongs_to :time_slot

  STATUSES = %w[present late early_leave absent].freeze

  validates :status, inclusion: { in: STATUSES }

  # 日本語ラベル
  def status_label
    case status
    when 'present'      then '出席'
    when 'late'         then '遅刻'
    when 'early_leave'  then '早退'
    when 'absent'       then '欠席'
    else status.to_s
    end
  end

  # 色
  def status_color
    case status
    when 'late'         then 'orange'
    when 'absent'       then 'red'
    when 'early_leave'  then 'blue'
    else 'green'
    end
  end

  # ===============================
  # 🔽 ここから自動欠席付与ロジック
  # ===============================
  def self.mark_auto_absent_for_past_slots!
    now   = Time.zone.now
    today = Date.current

    # 今日のコマだけ対象
    TimeSlot.where(date: today).includes(:attendances).find_each do |slot|
      # 授業開始時刻（date + start_time）
      lesson_start = Time.zone.local(
        slot.date.year, slot.date.month, slot.date.day,
        slot.start_time.hour, slot.start_time.min, slot.start_time.sec
      )

      cutoff = lesson_start + 30.minutes # 30分経過

      # まだ30分経ってないコマはスキップ
      next if now < cutoff

      # ✅ シンプル案：全 Student を「この授業を受ける前提」として扱う
      #   （もし将来、クラス分けや履修テーブルを作ったら、そこに差し替え）
      Student.find_each do |student|
        # すでに何か Attendance がある学生はスキップ
        next if student.attendances.exists?(time_slot: slot)

        create!(
          student:        student,
          time_slot:      slot,
          status:         'absent',
          registered_at:  cutoff,
          late_reason:    '登録がなかったため',
          admin_approval: true
        )
      end
    end
  end
end
