class AlarmCode < ApplicationRecord
  has_and_belongs_to_many :machine_series_nos

require 'csv'
def self.client_master
    CSV.generate do |csv|
  		CSV.open("#{Rails.root}/public/excel_client.csv","wb") do |csv|
            csv << ["s_no","parts_count","programe_number","total_run_second","total_cutting_second","date"]
            s_no = 1
            cli =  Machine.find(24).machine_monthly_logs.last(10000)
        	cli.each do|a|
             	  csv << [s_no, a.parts_count,a.programe_number,a.total_run_second,a.total_cutting_second,a.created_at]
            	  s_no = s_no + 1
              	    end
    		end
       	end
end


def self.mobile_app_new
  tenant = Tenant.find(params[:tenant_id])
  shift = Shifttransaction.current_shift(tenant.id)
  if shift.present?
  date = Date.today.to_s
   case
    when shift.day == 1 && shift.end_day == 1
      start_time = (date+" "+shift.shift_start_time).to_time
      end_time = (date+" "+shift.shift_end_time).to_time
    when shift.day == 1 && shift.end_day == 2
      if Time.now.strftime("%p") == "AM"
        start_time = (date+" "+shift.shift_start_time).to_time-1.day
        end_time = (date+" "+shift.shift_end_time).to_time
      else
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time+1.day
      end
    else
      start_time = (date+" "+shift.shift_start_time).to_time
      end_time = (date+" "+shift.shift_end_time).to_time
    end

    dur = Time.now.to_i - start_time.to_i

    duration = end_time.to_i - start_time.to_i
    tenant.machines.order(:id).map do |mac|
    cur_dur = Time.now.to_i - start_time.to_i
   
    machine_log = mac.machine_daily_logs.where("created_at >=? AND created_at <?",start_time,end_time).order(:id)
    
    if mac.controller_type == 1
      run_time = Machine.calculate_total_run_time(machine_log)
    else 
      run_time = Machine.run_time(machine_log)
    end
    
     utilization = (run_time*100)/duration
     stop_time = Machine.stop_time(machine_log)
     idle_time = Machine.ideal_time(machine_log)
      if machine_log.present?
        if machine_log.where(machine_status: 3).present?
      data = machine_log.where(machine_status: 3).pluck(:programe_number, :parts_count).uniq
      
      if data.count == 1 || data.count == 0
        cycle_time = 0
        parts = 0
        cutting_time = 0
      else
        if mac.controller_type == 1 
        cycle_time = machine_log.where(machine_status: 3, parts_count: data[-2][1]).last.run_time.to_i * 60 + machine_log.where(machine_status: 3, parts_count: data[-2][1]).last.run_second.to_i/1000
        cutting_time = (machine_log.where(parts_count: data[-2][1]).last.total_cutting_time.to_i * 60 + machine_log.where(parts_count: data[-2][1]).last.total_cutting_second.to_i/1000) - (machine_log.where(parts_count: data[-2][1]).first.total_cutting_time.to_i * 60 + machine_log.where(parts_count: data[-2][1]).first.total_cutting_second.to_i/1000)
        spindle_load = 0
        feed_rate = machine_log.pluck(:feed_rate).reject{|i| i == "" || i.nil? || i > 5000  }.last
        job_wise_parts = data.group_by{|x|x[0]}.map{|k,v| [k,v.size]}.to_h
        spindle_speed = machine_log.pluck(:cutting_speed).reject{|i| i == "" || i.nil?  }.last
        sp_temp = machine_log.last.z_axis
        else
         cycle_time = machine_log.where(machine_status: 3, parts_count: data[-2][1]).last.created_at - machine_log.where(machine_status: 3, parts_count: data[-2][1]).first.created_at
         cutting_time = cycle_time
         spindle_load = 0	
         feed_rate = 0
         sp_temp = 0
          job_wise_parts = 0
          spindle_speed = 0
        end
        parts = data.count
      end
    end
end

       time_diff =  dur - (run_time.to_i+stop_time.to_i+idle_time.to_i)

      if stop_time.to_i > run_time.to_i && stop_time.to_i > idle_time.to_i
        stop = stop_time.to_i + time_diff.to_i
      else
        stop = stop_time.to_i
      end

      if idle_time.to_i >= run_time.to_i && idle_time.to_i >= stop_time.to_i
        idle = idle_time.to_i + time_diff.to_i
      else
        idle = idle_time.to_i
      end

      if run_time.to_i > idle_time.to_i && run_time.to_i > stop_time.to_i
        run = run_time.to_i + time_diff.to_i
      else
        run = run_time.to_i
      end
     
     data = {
     	:unit=>mac.unit,
     	:day_start=>machine_log.first.present? ? machine_log.first.created_at.in_time_zone("Chennai") : 0,
      :machine_name => mac.machine_name,
      :machine_id => mac.id,
      :shift_no => shift.shift_no,
      :shift_time => shift.shift_start_time+ ' - ' +shift.shift_end_time,
      :job_name => mac.machine_daily_logs.where.not(:job_id=>"",:programe_number=>nil).order(:id).last.present? ? ""+mac.machine_daily_logs.where.not(:job_id=>"",:programe_number=>nil).order(:id).last.programe_number+"-"+mac.machine_daily_logs.where.not(:job_id=>"",:programe_number=>nil).order(:id).last.job_id : nil ,
      :parts_count => parts,
      :machine_disply => machine_log.last.present? ? machine_log.last.parts_count.to_i : 0,
      :utilization => utilization != nil ? utilization : 0,
      :job_wise_parts => job_wise_parts.present? ? job_wise_parts : 0,
      :run_time => run != nil ? Time.at(run).utc.strftime("%H:%M:%S") : "00:00:00",
      :idle_time => idle != nil ?  idle > 0 ? Time.at(idle).utc.strftime("%H:%M:%S") : "00:00:00" : "00:00:00",
      :stop_time => stop != nil ? stop > 0 ? Time.at(stop).utc.strftime("%H:%M:%S") : "00:00:00" : "00:00:00",
      :cycle_time => cycle_time.present? ? Time.at(cycle_time).utc.strftime("%H:%M:%S") : "00:00:00",
      :cutting_time => cutting_time.present? ? Time.at(cutting_time).utc.strftime("%H:%M:%S") : "00:00:00",
      :machine_status => machine_log.last.present? ? (Time.now - machine_log.last.created_at) > 600 ? nil : machine_log.last.machine_status : nil,
      :feed_rate => feed_rate.present? ? feed_rate : 0,
      :spindle_load => spindle_load.present? ?  spindle_load : 0,
      :spindle_speed => spindle_speed.present? ? spindle_speed : 0,
      :sp_temp => sp_temp,
       :start_time=>start_time
       #:report =>'report'
     }
    end
   else
    data = { message:"No shift Currently Available" }
  end

end







end
