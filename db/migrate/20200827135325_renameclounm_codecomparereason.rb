class RenameclounmCodecomparereason < ActiveRecord::Migration[5.0]
  def change
    rename_column :code_compare_reasons, :customer, :customername
    rename_column :code_compare_reasons, :job_number, :job_name


  end
end
