class ChangeContentToArray < ActiveRecord::Migration[5.2]
  def change
    remove_column :documents, :content
    add_column :documents, :content, :text, array: true, default: []
  end
end
