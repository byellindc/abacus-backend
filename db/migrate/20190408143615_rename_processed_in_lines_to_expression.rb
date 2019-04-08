class RenameProcessedInLinesToExpression < ActiveRecord::Migration[5.2]
  def change
    rename_column :lines, :processed, :expression
  end
end
