class ExternalMachineLog < ActiveRecord::Base
    belongs_to :machine, -> { with_deleted }
    belongs_to :cncjob ,optional:true
    serialize :x_axis, Array
    serialize :y_axis, Array
    serialize :cycle_time_minutes, Array

   # serialize :status, Array
   # serialize :x_axis, Array
   # serialize :y_axis, Array
   # serialize :cycle_time_minutes, Array
   establish_connection("#{Rails.env}_sec".to_sym)
   self.table_name = "machine_logs"
   #ExternalDatabaseConnection

end
