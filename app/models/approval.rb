class Approval < ApplicationRecord
has_many :users#,:dependent => :destroy
 
   def self.record
  	require 'csv'
  	machines = Machine.where(id: [8])
  	machines.each do |machine|
  	  logs = machine.machine_logs#.where(created_at: Date.yesterday.end_of_day - 6.months..Date.yesterday.end_of_day)
          
          
         path = "#{Rails.root}/public/exl_#{machine.id}.csv"
	  CSV.open(path, "wb") do |csv|
		 csv << ["parts_count", "machine_status", "job_id", "total_run_time", "total_cutting_time", "run_time", "feed_rate", "cutting_speed", "axis_load", "axis_name", "spindle_speed", "spindle_load", "total_run_second", "programe_number", "programe_description", "run_second", "machine_id", "created_at", "updated_at", "machine_time", "cycle_time_minutes", "machine_total_time", "cycle_time_per_part", "total_cutting_second", "x_axis", "y_axis", "z_axis", "reason"]
	     # csv << ["Date", "Shift", "Time", "Operator Name", "Operator ID", "Machine Name", "Machine ID", "Program Number", "Job Description", "Parts Produced", "CycleTime(M:S)", "Idle Time(Hrs)", "Stop Time(Hrs)", "Actual Running(Hrs)", "Actual Working Hours", "Utilization(%.)"]
	    logs.each do |detail|
          csv << [detail.parts_count, detail.machine_status, detail.job_id, detail.total_run_time, detail.total_cutting_time, detail.run_time, detail.feed_rate, detail.cutting_speed, detail.axis_load, detail.axis_name, detail.spindle_speed, detail.spindle_load, detail.total_run_second, detail.programe_number, detail.programe_description, detail.run_second, detail.machine_id, detail.created_at, detail.updated_at, detail.machine_time, detail.cycle_time_minutes, detail.machine_total_time, detail.cycle_time_per_part, detail.total_cutting_second, detail.x_axis, detail.y_axis, detail.z_axis, detail.reason]
	    end
	  end
    end
  end


 def self.xls_sheet
require 'creek'
require 'roo'
require 'roo-xls'
require 'write_xlsx'
require 'byebug'

machines = Machine.where(id: [6])
  machines.each do |machine|

workbook = WriteXLSX.new('/home/ubuntu/imtex/imtex2019/public/test123.xlsx')
worksheet = workbook.add_worksheet
 data = machine.machine_logs
 data.each_with_index do |k,index|
  worksheet.write(index, 0, k.parts_count)
  worksheet.write(index, 1, k.machine_status)
  worksheet.write(index, 2, k.job_id)
  worksheet.write(index, 3, k.total_run_time)
  worksheet.write(index, 4, k.total_cutting_time)
  worksheet.write(index, 5, k.run_time)
  worksheet.write(index, 6, k.feed_rate)
  worksheet.write(index, 7, k.cutting_speed)
  worksheet.write(index, 8, k.axis_load)
  worksheet.write(index, 9, k.axis_name)
  worksheet.write(index, 10, k.spindle_speed)
  worksheet.write(index, 11, k.spindle_load)
  worksheet.write(index, 12, k.total_run_second)
  worksheet.write(index, 13, k.programe_number)
  worksheet.write(index, 14, k.programe_description)
  worksheet.write(index, 15, k.run_second)
  worksheet.write(index, 16, k.machine_id)
  worksheet.write(index, 17, k.created_at)
  worksheet.write(index, 18, k.updated_at)
  worksheet.write(index, 19, k.machine_time)
  worksheet.write(index, 20, k.cycle_time_minutes)
  worksheet.write(index, 21, k.machine_total_time)
  worksheet.write(index, 22, k.cycle_time_per_part)
  worksheet.write(index, 23, k.total_cutting_second)
  worksheet.write(index, 24, k.x_axis)
  worksheet.write(index, 25, k.y_axis)
  worksheet.write(index, 26, k.z_axis)
  worksheet.write(index, 27, k.reason)
 end
   workbook.close

end
end



 def self.xls_sheet1
require 'creek'
require 'roo'
require 'roo-xls'
require 'write_xlsx'
require 'byebug'

machines = Machine.where(id: [6])
  machines.each do |machine|
some = 2
workbook = WriteXLSX.new('/home/ubuntu/imtex/imtex2019/public/test2.xlsx')
worksheet = workbook.add_worksheet
 data = machine.machine_logs
 data.each_slice(50000).each do |ind|
 ind.each_with_index do |k,index|
  worksheet.write(index, 0, k.parts_count)
  worksheet.write(index, 1, k.machine_status)
  worksheet.write(index, 2, k.job_id)
  worksheet.write(index, 3, k.total_run_time)
  worksheet.write(index, 4, k.total_cutting_time)
  worksheet.write(index, 5, k.run_time)
  worksheet.write(index, 6, k.feed_rate)
  worksheet.write(index, 7, k.cutting_speed)
  worksheet.write(index, 8, k.axis_load)
  worksheet.write(index, 9, k.axis_name)
  worksheet.write(index, 10, k.spindle_speed)
  worksheet.write(index, 11, k.spindle_load)
  worksheet.write(index, 12, k.total_run_second)
  worksheet.write(index, 13, k.programe_number)
  worksheet.write(index, 14, k.programe_description)
  worksheet.write(index, 15, k.run_second)
  worksheet.write(index, 16, k.machine_id)
  worksheet.write(index, 17, k.created_at)
  worksheet.write(index, 18, k.updated_at)
  worksheet.write(index, 19, k.machine_time)
  worksheet.write(index, 20, k.cycle_time_minutes)
  worksheet.write(index, 21, k.machine_total_time)
  worksheet.write(index, 22, k.cycle_time_per_part)
  worksheet.write(index, 23, k.total_cutting_second)
  worksheet.write(index, 24, k.x_axis)
  worksheet.write(index, 25, k.y_axis)
  worksheet.write(index, 26, k.z_axis)
  worksheet.write(index, 27, k.reason)
 end
   workbook.close
   some = some+1
   workbook = WriteXLSX.new("/home/ubuntu/imtex/imtex2019/public/test'#{some}'.xlsx")
   worksheet = workbook.add_worksheet
   puts some
  end 
end
end








end
