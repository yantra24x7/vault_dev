class CodeCompareReason < ApplicationRecord
  mount_uploader :part_doc_path, FileUploader
  belongs_to :user
  belongs_to :machine

  enum current_location: {"Upload to Master"=> 1, "Delete"=> 2, "Backup"=> 3, "Upload to Backup"=> 4, "Code Compare"=> 5}

  def self.data_s(params)

   a = params[:search] + "*"
   #byebug
   find_by_sql [ "SELECT * FROM code_compare_reasons WHERE MATCH (part_number, user_name, customername, description, job_name, prog_num, old_revision_no, new_revision_no) AGAINST ('#{a}' IN NATURAL LANGUAGE MODE)" ]
   #find_by_sql [ "SELECT * FROM code_compare_reasons WHERE MATCH (part_number, user_name, customername, description, job_name, prog_num, old_revision_no, new_revision_no) AGAINST ('#{a}' IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION)" ]
   
end

end
