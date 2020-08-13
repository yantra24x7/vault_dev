class Material < ApplicationRecord
  belongs_to :cncjob
  belongs_to :tenant


require 'csv'

def self.emd_type
  		CSV.generate do |csv|
  		CSV.open("#{Rails.root}/public/file.csv","wb") do |csv|
        
            csv << ["S.NO","email","password"]
            s_no = 1
            mac = User.all
            mac.each do|i|
            emd = User.find(i.id)
            csv<<[s_no, emd.email_id, emd.default]
                s_no = s_no + 1
       	    end
 		end
   	end
end


end
