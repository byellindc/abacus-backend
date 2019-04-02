class AddUpdatedToLine < ActiveRecord::Migration[5.2]
  def change
    add_column :lines, :updated, :boolean
  end
end
