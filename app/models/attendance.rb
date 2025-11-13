class Attendance < ApplicationRecord
  belongs_to :student
  belongs_to :time_slot
  
  validates :status, presence: true
  validates :student_id, uniqueness: { scope: :time_slot_id }
  
  # status: 'present', 'late', 'absent'
end