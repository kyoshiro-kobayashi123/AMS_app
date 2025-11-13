class AddDetailToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :detail, :text
  end
end
