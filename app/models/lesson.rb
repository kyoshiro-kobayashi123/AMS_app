class Lesson < ApplicationRecord
  belongs_to :faculty
  has_many :time_slots, dependent: :destroy
  
  validates :lesson_name, presence: true
end