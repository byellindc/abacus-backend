class CreateLines < ActiveRecord::Migration[5.2]
  def change
    create_table :lines do |t|
      t.references :document, foreign_key: true
      t.string :input
      t.string :processed
      t.string :name
      t.decimal :result

      t.timestamps
    end
  end
end
