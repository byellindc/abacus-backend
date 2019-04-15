class RenameContentToContents < ActiveRecord::Migration[5.2]
  def change
    rename_column :documents, :content, :contents
  end
end
