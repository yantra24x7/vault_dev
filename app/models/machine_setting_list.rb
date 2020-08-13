class MachineSettingList < ApplicationRecord
  belongs_to :machine_setting

 def self.machine_setting_list(params)
    mac = Machine.find(params[:machine_id]).machine_setting.machine_setting_lists
	return mac
 end

end
