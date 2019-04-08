class AddModeToLines < ActiveRecord::Migration[5.2]
  def change
    add_column :lines, :mode, :text
  end
end
