class AddClassroomIdToTimeSlots < ActiveRecord::Migration[8.0]
  def change
    add_column :time_slots, :classroom_id, :integer
  end
end
