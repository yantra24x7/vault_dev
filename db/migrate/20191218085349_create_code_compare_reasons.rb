class CreateCodeCompareReasons < ActiveRecord::Migration[5.0]
  def change
    create_table :code_compare_reasons do |t|
      t.string :user_name
      t.references :machine, foreign_key: true
      t.string :description
      t.datetime :create_date
      t.string :old_revision_no
      t.string :new_revision_no
      t.string :file_name

      t.timestamps
    end
  end
end
