# app/models/attendance.rb
class Attendance < ApplicationRecord
  belongs_to :student
  belongs_to :time_slot

  STATUSES = %w[present late early_leave absent].freeze

  validates :status, inclusion: { in: STATUSES }
end
