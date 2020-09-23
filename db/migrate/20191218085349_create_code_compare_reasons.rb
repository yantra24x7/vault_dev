class CreateCodeCompareReasons < ActiveRecord::Migration[5.0]
  def change
    create_table :code_compare_reasons do |t|
      t.string :part_number
      t.string :user_name
      t.references :machine, foreign_key: true
      t.references :user, foreign_key: true
      t.string :customer
      t.string :description
      t.datetime :edit_date
      t.string :job_number
      t.string :prog_num
      t.datetime :create_date
      t.string :old_revision_no
      t.string :new_revision_no
      t.string :file_name
      t.string :prg_file_path
      t.string :part_doc_path
      t.boolean :is_active

      t.timestamps
    end
  end
end
