
##   every 1.day, at: '12:01 am' do
  # command "/usr/bin/some_great_command"
##   runner "CncReport.delay_jobs1",:environment => :development
##  end
  
#   every 10.minutes do
 #  runner "Machine.alert_mail",:environment => :development
 # end



  # every 20.minutes do
  #  #command "/usr/bin/some_great_command"
  #  runner "CncReport.cnc_report_speed",:environment => :development
  #every 15.minutes do 
  #  runner "MachineDailyLog.consolidate_data",:environment => :development
  #end

  every :sunday, at: '12pm' do
   command "/usr/bin/cmd"
  rake "log:clear"
  end

  every 1.day, at: '12am' do
	runner "CncReport.delay_jobs1", :environment => 'development'
  end
  
  every :reboot do
	runner "screen rake jobs:work"
  end

 ## every 1.day, at: '01:30 am' do
 ##   runner "MachineDailyLog.delete_data",:environment => :development
 ## end



 

