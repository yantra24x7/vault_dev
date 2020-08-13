class CtReport < ApplicationRecord
  belongs_to :operator, :optional=>true
  belongs_to :machine
  belongs_to :shift
  belongs_to :tenant



  def self.cnc_report_simple_query_r(tenant, shift_no, date)
    date = date
    @alldata = []
    send_part = []
    
    shifts = Shifttransaction.includes(:shift).where(shifts: {tenant_id: tenant})
    shift = shifts.find_by_shift_no(shift_no)
     
     case
      when shift.day == 1 && shift.end_day == 1
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
      when shift.day == 1 && shift.end_day == 2
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time+1.day
      else
        start_time = (date+" "+shift.shift_start_time).to_time+1.day
        end_time = (date+" "+shift.shift_end_time).to_time+1.day
      end
      machine_ids = Tenant.find(tenant).machines.where(controller_type: 2).pluck(:id)
      full_log2 = ExternalMachineDailyLog.where(machine_id: machine_ids)
      full_log = full_log2.group_by{|x| x.machine_id}      
      
      machine_log11 = full_log2.select{|a| a[:created_at] >= start_time && a[:created_at] < end_time}.group_by{|x| x.machine_id}  
      
      mac_ids = machine_log11.keys 
      bls = machine_ids - mac_ids
      mer_req = bls.map{|i| [i,[]]}.to_h      
      machine_log = machine_log11.merge(mer_req)
      full_logs = full_log.merge(mer_req) ##1##
      
      machine_log.each do |key, value|
        value1 = full_logs[key]
        job_description = value.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
        ff = value.group_by{|i| [i.parts_count, i.programe_number]}
        
        run_time = Machine.run_time(value)
        stop_time = Machine.stop_time(value)
        ideal_time = Machine.ideal_time(value)
        @part_time = BreakTime.parts_time_r3(value, value1,shift_no,shift.id, date)

		send_part << @part_time
		part_time1 = @part_time.select{|a| a[:time] >= start_time && a[:time] < end_time } 
		cycle_st_to_st = part_time1.pluck(:cycle_st_to_st).map{|i| i.to_i}
		cutting_time = part_time1.pluck(:cutting_time).map{|i| i.to_i}
		cycle_stop_to_stop = part_time1.pluck(:cycle_stop_to_stop).map{|i| i.to_i}
		cycle_time = part_time1.pluck(:cycle_time).flatten
		
		duration = (end_time - start_time).to_i
		time_diff = duration - (run_time+stop_time+ideal_time)
		utilization =(run_time*100)/duration if duration.present?

		if shift.operator_allocations.where(machine_id: key).last.nil?
		  operator_id = nil
		  target = 0
		else
		  if shift.operator_allocations.where(machine_id: key).present?
		    shift.operator_allocations.where(machine_id: key).each do |ro|
		      aa = ro.from_date
		      bb = ro.to_date
		      cc = date
		      if cc.to_date.between?(aa.to_date,bb.to_date)
			dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
			if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
			  operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id
			  target = dd.operator_mapping_allocations.where(:date=>date.to_date).last.target
			else
			  operator_id = nil
			  target = 0
			end
		      else
			operator_id = nil
			target = 0
		      end
		    end
		  else
		    operator_id = nil
		    target = 0
		  end
		end

		data4 = ShiftPart.where(date: date, machine_id:key, shift_no: shift.shift_no)
		data_parts_count = data4.count
		approved = data4.where(status: 1).count
		rework = data4.where(status: 2).count
		rejected = data4.where(status: 3).count

		if target == 0
		  pending = 0
		else
		  pending = target - data_parts_count
		end

		# feed_rate_min = machine_log1.pluck(:feed_rate).reject{|i| i == "" || i.nil? || i > 5000 || i == 0 }.map(&:to_i).min
		feed_rate_max = value.pluck(:feed_rate).reject{|i| i == "" || i.nil? || i > 5000 || i == 0 }.map(&:to_i).max
		 
		# spindle_speed_min = machine_log1.pluck(:cutting_speed).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min
		spindle_speed_max = value.pluck(:cutting_speed).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max
		
		sp_temp_min = value.pluck(:z_axis).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min
		sp_temp_max = value.pluck(:z_axis).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max

		spindle_load_min = value.pluck(:spindle_load).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min
		spindle_load_max = value.pluck(:spindle_load).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max

	       
		mac_setting_id =  MachineSetting.find_by(machine_id: key).id     
		data_val = MachineSettingList.where(machine_setting_id: mac_setting_id, is_active: true).pluck(:setting_name)
		 
		axis_loadd = []
		tempp_val = []
		puls_coder = []
		
		if value.present?
		  unless value.first.machine.controller_type == 2
		    value.last.x_axis.first.each_with_index do |key, index|
		      if data_val.include?(key[0].to_s)
			# key = 0
			load_value =  value.pluck(:x_axis).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min.to_s+' - '+value.pluck(:x_axis).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max.to_s
			temp_value =  value.pluck(:y_axis).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min.to_s+' - '+value.pluck(:y_axis).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max.to_s
			puls_value =  value.pluck(:cycle_time_minutes).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min.to_s+' - '+value.pluck(:cycle_time_minutes).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max.to_s
			
			if load_value == " - "
			  load_value = "0 - 0" 
			end

			if temp_value == " - "
			  temp_value = "0 - 0" 
			end

			if puls_value == " - "
			  puls_value = "0 - 0" 
			end
		      
			axis_loadd << {key[0].to_s.split(":").first => load_value}
			tempp_val << {key[0].to_s.split(":").first => temp_value}
			puls_coder << {key[0].to_s.split(":").first => puls_value}
		      else
			axis_loadd << {key[0].to_s.split(":").first => "0 - 0"}
			tempp_val <<  {key[0].to_s.split(":").first => "0 - 0"}
			puls_coder << {key[0].to_s.split(":").first => "0 - 0"}
		      end
		    end
		  end
		end

		if OeeCalculation.where(date: date, machine_id: key, shifttransaction_id: shift.id).present?
		  oee_part = OeeCalculation.where(date: date, machine_id: key, shifttransaction_id: shift.id).last.oee_calculate_lists       
		  oee_part.each do |pgn|  
		    oee_perfomance << (pgn.run_rate.to_i * pgn.parts_count.to_i)/(pgn.time.to_i).to_f
		    shift_part_count = ShiftPart.where(date: date, machine_id: key, shifttransaction_id: shift.id, program_number: pgn.program_number) 
		    if shift_part_count.count == 0
		      oee_qty << 0
		    else
		      good_pieces = shift_part_count.where(status: 1).count
		      oee_qty << (good_pieces)/(pgn.parts_count.to_i).to_f
		    end
		  end
		else
		  oee_perfomance = [0]
		  oee_qty = [0]
		end
		 
		avialabilty = 1
		perfomance = oee_perfomance.inject{ |sum, el| sum + el }.to_f / oee_perfomance.size
		quality = oee_qty.inject{ |sum, el| sum + el }.to_f / oee_qty.size
		 @alldata << [
			      date,
			      start_time.strftime("%H:%M:%S")+' - '+end_time.strftime("%H:%M:%S"),
			      duration,
			      shift.shift.id,
			      shift.shift_no,
			      operator_id,
			      key,
			      job_description.nil? ? "-" : job_description.split(',').join(" & "),
			      cutting_time.count,#new_parst_count,
			      run_time,
			      ideal_time,
			      stop_time,
			      time_diff,
			      cutting_time.count, #count,
			      utilization,
			      tenant,#tenant.id,
			      cycle_time,
			      cycle_st_to_st,#start_cycle_time,
			      feed_rate_max.to_s,
			      spindle_speed_max.to_s,
			      cutting_time.count,#data_parts_count,
			      target,
			      pending,
			      approved,
			      rework,
			      rejected,
			      cycle_stop_to_stop,#stop_to_start,
			      cutting_time,
			      spindle_load_min.to_s+' - '+spindle_load_max.to_s,
			      sp_temp_min.to_s+' - '+sp_temp_max.to_s,
			      axis_loadd,
                      tempp_val,
                      puls_coder,
                      avialabilty,
                      perfomance,
                      quality
                     ]
      
       end
       
    if @alldata.present?
      @alldata.each do |data|
        if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
          CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: [], cycle_start_to_start: data[17], feed_rate: data[18], spendle_speed: data[19], data_part: data[20], target:data[21], approved: data[23], rework: data[24], reject: data[25], stop_to_start: data[26], cutting_time: data[27],spindle_load: data[28], spindle_m_temp: data[29], servo_load: data[30], servo_m_temp: data[31], puls_code: data[32],availability: 0, perfomance: data[34], quality: data[35],parts_data: data[16])
        else
          CncReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: [], cycle_start_to_start:data[17], feed_rate: data[18], spendle_speed: data[19], data_part: data[20], target:data[21], approved: data[23], rework: data[24], reject: data[25], stop_to_start: data[26], cutting_time: data[27],spindle_load: data[28], spindle_m_temp: data[29], servo_load: data[30], servo_m_temp: data[31], puls_code: data[32],availability: data[33], perfomance: data[34], quality: data[35], parts_data: data[16])
        end
      end
    end
    
    data = CtReport.cnc_report_simple_query_hour_r(tenant, shift_no, date, send_part)
    puts "ok"
   end

   def self.cnc_report_simple_query_hour_r(tenant, shift_no, date, data)
    date = date
    @alldata = []
     shifts = Shifttransaction.includes(:shift).where(shifts: {tenant_id: tenant})
     shift = shifts.find_by_shift_no(shift_no)
     case
      when shift.day == 1 && shift.end_day == 1
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
      when shift.day == 1 && shift.end_day == 2
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time+1.day
      else
        start_time = (date+" "+shift.shift_start_time).to_time+1.day
        end_time = (date+" "+shift.shift_end_time).to_time+1.day
      end
      
      machine_ids = Tenant.find(tenant).machines.where(controller_type: 2).pluck(:id)
      full_logs = ExternalMachineDailyLog.where(machine_id: machine_ids).group_by{|x| x.machine_id}

       (start_time.to_i..end_time.to_i).step(3600) do |hour|
        (hour.to_i+3600 <= end_time.to_i) ? (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(hour.to_i+3600).strftime("%Y-%m-%d %H:%M")) : (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(end_time).strftime("%Y-%m-%d %H:%M"))
        unless hour_start_time[0].to_time == hour_end_time.to_time          
           machine_log = ExternalMachineDailyLog.where(created_at: hour_start_time[0].to_time..(hour_end_time.to_time-1), machine_id: machine_ids).group_by{|x| x.machine_id}
            mac_ids = machine_log.keys 
            bls = machine_ids - mac_ids  
            mer_req = bls.map{|i| [i,[]]}.to_h
            machine_log = machine_log.merge(mer_req)
            full_logs = full_logs.merge(mer_req) ##1##


           machine_log.each do |key, value|
            value1 = full_logs[key]
            run_time = Machine.run_time(value)
            stop_time = Machine.stop_time(value)
            ideal_time = Machine.ideal_time(value)
            
            #part_time = Shift.parts_time3(value, value1)
            
            find_data = data.flatten.select{|i| i[:machine_id] == key }
            final_data = find_data.select{|i| i[:time] >= hour_start_time[0].to_time && i[:time] <= (hour_end_time.to_time-1)}
            

            #cycle_st_to_st = @part_time.pluck(:cycle_st_to_st).map{|i| i.to_i}
            cutting_time = final_data.pluck(:cutting_time).map{|i| i.to_i}
            #cycle_stop_to_stop = @part_time.pluck(:cycle_stop_to_stop).map{|i| i.to_i}
            cycle_time = final_data.pluck(:cycle_time).flatten


            job_description = value.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
            duration = hour_end_time.to_time.to_i - hour_start_time[0].to_time.to_i

            time_diff = duration - (run_time+stop_time+ideal_time)
            utilization =(run_time*100)/duration if duration.present?
            
           

            if shift.operator_allocations.where(machine_id: key).last.nil?
			        operator_id = nil
			        target = 0
			      else
			        if shift.operator_allocations.where(machine_id: key).present?
			          shift.operator_allocations.where(machine_id: key).each do |ro|
			            aa = ro.from_date
			            bb = ro.to_date
			            cc = date
			            if cc.to_date.between?(aa.to_date,bb.to_date)
			              dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
			              if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
			                operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id
			                target = dd.operator_mapping_allocations.where(:date=>date.to_date).last.target
			              else
			                operator_id = nil
			                target = 0
			              end
			            else
			              operator_id = nil
			              target = 0
			            end
			          end
			        else
			          operator_id = nil
			          target = 0
			        end
			      end
            
            # feed_rate_min = machine_log1.pluck(:feed_rate).reject{|i| i == "" || i.nil? || i > 5000 || i == 0 }.map(&:to_i).min
            feed_rate_max = value.pluck(:feed_rate).reject{|i| i == "" || i.nil? || i > 5000 || i == 0 }.map(&:to_i).max
             
          # spindle_speed_min = machine_log1.pluck(:cutting_speed).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min
            spindle_speed_max = value.pluck(:cutting_speed).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max
            
            sp_temp_min = value.pluck(:z_axis).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min
            sp_temp_max = value.pluck(:z_axis).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max

            spindle_load_min = value.pluck(:spindle_load).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min
            spindle_load_max = value.pluck(:spindle_load).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max

           
            mac_setting_id =  MachineSetting.find_by(machine_id: key).id     
            data_val = MachineSettingList.where(machine_setting_id: mac_setting_id, is_active: true).pluck(:setting_name)
             
            axis_loadd = []
            tempp_val = []
            puls_coder = []
            
            if value.present?
              unless value.first.machine.controller_type == 2
                value.last.x_axis.first.each_with_index do |key, index|
                  if data_val.include?(key[0].to_s)
                    # key = 0
                    load_value =  value.pluck(:x_axis).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min.to_s+' - '+value.pluck(:x_axis).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max.to_s
                    temp_value =  value.pluck(:y_axis).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min.to_s+' - '+value.pluck(:y_axis).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max.to_s
                    puls_value =  value.pluck(:cycle_time_minutes).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).min.to_s+' - '+value.pluck(:cycle_time_minutes).sum.pluck(key[0]).reject{|i| i == "" || i.nil? || i == 0 }.map(&:to_i).max.to_s
                    
                    if load_value == " - "
                      load_value = "0 - 0" 
                    end

                    if temp_value == " - "
                      temp_value = "0 - 0" 
                    end

                    if puls_value == " - "
                      puls_value = "0 - 0" 
                    end
                  
                    axis_loadd << {key[0].to_s.split(":").first => load_value}
                    tempp_val << {key[0].to_s.split(":").first => temp_value}
                    puls_coder << {key[0].to_s.split(":").first => puls_value}
                  else
                    axis_loadd << {key[0].to_s.split(":").first => "0 - 0"}
                    tempp_val <<  {key[0].to_s.split(":").first => "0 - 0"}
                    puls_coder << {key[0].to_s.split(":").first => "0 - 0"}
                  end
                end
              end
            end
          
            @alldata << [
               date,
               hour_start_time[0].split(" ")[1]+' - '+hour_end_time.split(" ")[1],
               duration,
               shift.shift.id,
               shift.shift_no,
               operator_id,
               key,
               job_description.nil? ? "-" : job_description.split(',').join(" & "),
               cutting_time.count,
               run_time,
               ideal_time,
               stop_time,
               time_diff,
               value.count,
               utilization,
               tenant.to_i,
               cycle_time,
               cutting_time,  
               spindle_load_min.to_s+' - '+spindle_load_max.to_s,
               sp_temp_min.to_s+' - '+sp_temp_max.to_s,
               axis_loadd,
               tempp_val,
               puls_coder,
               feed_rate_max.to_s,
               spindle_speed_max.to_s
            ]
           end
        end
      end
     
       if @alldata.present?
      @alldata.each do |data|
        if CncHourReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
          CncHourReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], ideal_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16],cutting_time: data[17],spindle_load: data[18],spindle_m_temp: data[19],servo_load: data[20], servo_m_temp: data[21], puls_code: data[22],feed_rate:data[23], spendle_speed:data[24])
        else
          CncHourReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], ideal_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16],cutting_time: data[17],spindle_load: data[18],spindle_m_temp: data[19],servo_load: data[20], servo_m_temp: data[21], puls_code: data[22],feed_rate:data[23], spendle_speed:data[24])
        end
      end
      end
   end



end
