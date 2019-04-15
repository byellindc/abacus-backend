class AddContentToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :content, :text
  end
end
