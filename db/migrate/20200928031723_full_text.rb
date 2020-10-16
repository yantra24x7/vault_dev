class FullText < ActiveRecord::Migration[5.0]
  def change
  add_index :code_compare_reasons, [:part_number, :user_name, :customername, :description, :job_name,  :prog_num, :old_revision_no, :new_revision_no], name: 'search_name_description', type: :fulltext
  end
end
