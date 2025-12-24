class TimeSlot < ApplicationRecord
  belongs_to :lesson
  belongs_to :classroom, optional: true
  has_many :attendances, dependent: :destroy
  # has_many :absences, dependent: :destroy
  
  validates :date, :start_time, :end_time, presence: true

end