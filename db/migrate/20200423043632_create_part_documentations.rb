class CreatePartDocumentations < ActiveRecord::Migration[5.0]
  def change
    create_table :part_documentations do |t|
      t.string :part_number
      t.references :customer, foreign_key: true
      t.references :machine, foreign_key: true
      t.string :program_number
      t.string :revision_no
      t.string :editor
      t.string :part_produced_in_this_setup
      t.string :job_number
      t.string :part_drawing

      t.timestamps
    end
  end
end
