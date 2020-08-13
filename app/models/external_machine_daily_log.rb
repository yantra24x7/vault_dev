class ExternalMachineDailyLog < ActiveRecord::Base
    serialize :status, Array
    serialize :x_axis, Array
    serialize :y_axis, Array
    serialize :cycle_time_minutes, Array
    belongs_to :machine
   establish_connection("#{Rails.env}_sec".to_sym)
   self.table_name = "machine_daily_logs"
   #ExternalDatabaseConnection

end
