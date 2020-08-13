class CodeCompareReason < ApplicationRecord
  belongs_to :user
  belongs_to :machine

  enum current_location: {"Upload to Master"=> 1, "Delete"=> 2, "Backup"=> 3, "Upload to Backup"=> 4, "Code Compare"=> 5}

end
