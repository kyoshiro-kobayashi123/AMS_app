class Absence < ApplicationRecord
  belongs_to :student
  belongs_to :time_slot
  
  validates :kind, :reason, presence: true
  
  # kind: '病欠', '公欠', '忌引', etc.
end