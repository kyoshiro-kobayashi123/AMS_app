class TimeSlot < ApplicationRecord
  belongs_to :lesson
  has_many :attendances, dependent: :destroy
  has_many :absences, dependent: :destroy
  
  validates :date, :start_time, :end_time, presence: true
end