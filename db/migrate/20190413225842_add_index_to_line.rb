class AddIndexToLine < ActiveRecord::Migration[5.2]
  def change
    add_column :lines, :index, :integer
  end
end
