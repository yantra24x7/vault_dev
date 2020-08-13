class AlarmHistory < ApplicationRecord
  belongs_to :machine

 def self.cnc_rep_change
  CncReport.where(id: [67729, 67730, 67731, 67732, 67733, 67734, 67735, 67736, 67737, 67738, 67739, 67740, 67741, 67742, 67743]).each do |data|
    if data.id == 31
    puts data.id
    else 
    data.update(parts_data: data.all_cycle_time)
    puts data.id
    end
  end
end


def self.alarm_histories_report(tenant, shift_no, date)
    date = date
    @alldata = []
    tenant = Tenant.find(tenant)
    machines = tenant.machines.where(controller_type: 1)
    shift = tenant.shift.shifttransactions.where(shift_no: shift_no).last 
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
      machines.order(:id).map do |mac|
        alarms = mac.alarm_tests.where("time >= ? AND time <= ?",start_time.utc.to_time,end_time.utc.to_time).order(:id)
      

        if shift.operator_allocations.where(machine_id:mac.id).last.nil?
        operator_id = nil
        target = 0
      else
        if shift.operator_allocations.where(machine_id:mac.id).present?
        shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
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
      
      if alarms.present?
        alarms.each do |io|
          @alldata << [
              date,  
              shift.shift_no,  
              io.time,
              io.message, 
              io.alarm_no,  
              io.alarm_type,
              io.axis_no,
              io.category,  
              io.machine_id,  
              shift.shift.id,  
              tenant.id,
              operator_id
           ]
        end
      end
      end

      if @alldata.present?
        @alldata.each do |data|
          if AlarmReport.where(date: data[0], shift_no: data[1], alarm_time: data[2], message:data[3], alarm_no: data[4], alarm_type: data[5], machine_id: data[8], shift_id: data[9], operator_id: data[11]).present?
            puts "Go Go"
          else
            AlarmReport.create(date: data[0], shift_no: data[1], alarm_time: data[2], message:data[3], alarm_no: data[4], alarm_type: data[5], axis_no: data[6], category: data[7], machine_id: data[8], shift_id: data[9], tenant_id: data[10], operator_id: data[11])
          end 
        end
      end
  end











   def self.alarm_histories_report1(params)
      date = params[:start_date]
      tenant=Tenant.find(params[:tenant_id])
      machines=params[:machine_id].present? ? Machine.where(id:params[:machine_id]) : tenant.machines 
      shiftstarttime=tenant.shift.day_start_time
      if params[:report_type] == "Shiftwise"
      	
        (params[:start_date].to_date..params[:end_date].to_date).map(&:to_s).map do |date|	
          shifts = params[:shift_id].present? ? Shifttransaction.where(id:params[:shift_id]) : tenant.shift.shifttransactions
           shifts.map do |shift|
           	
              # if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
              #       start_time = (date+" "+shift.shift_start_time).to_time
              #       end_time = (date+" "+shift.shift_end_time).to_time+1.day        
              # elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")
              #       start_time = (date+" "+shift.shift_start_time).to_time+1.day
              #       end_time = (date+" "+shift.shift_end_time).to_time+1.day
              # else
              #       start_time = (date+" "+shift.shift_start_time).to_time
              #       end_time = (date+" "+shift.shift_end_time).to_time        
              # end

        if tenant.id != 31 || tenant.id != 10
          if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
            if Time.now.strftime("%p") == "AM"
              date = (Date.today - 1).strftime("%Y-%m-%d")
            end 
            start_time = (date+" "+shift.shift_start_time).to_time
            end_time = (date+" "+shift.shift_end_time).to_time+1.day                       
          elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")                
            if Time.now.strftime("%p") == "AM"
              date = (Date.today - 1).strftime("%Y-%m-%d")
            end
              start_time = (date+" "+shift.shift_start_time).to_time+1.day
              end_time = (date+" "+shift.shift_end_time).to_time+1.day
          else
            start_time = (date+" "+shift.shift_start_time).to_time
            end_time = (date+" "+shift.shift_end_time).to_time        
          end
        else
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
        end


              
                end_time_for_ideal = Time.now < end_time ? Time.now : end_time
                total_shift_time_available = Time.parse(shift.actual_working_hours).seconds_since_midnight
              machines.map do | machine|
              	
               machine.alarm_histories.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id).map do | alarm|
           
                 operator_name = shift.operator_allocations.where(machine_id:machine.id).last.nil? ?  "Not Assigned" : shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.present? ? shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.operator.operator_name : "Not Assigned"
                 operator_id = shift.operator_allocations.where(machine_id:machine.id).last.nil? ?  "Not Assigned" : shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.present? ? shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.operator.operator_spec_id : "Not Assigned"
                 update=alarm.updated_at.strftime("%H:%M:%S")
                 create=alarm.created_at.strftime("%H:%M:%S")
                duration =  update.to_time - create.to_time
                
                  data ={
                  date:date,
                  time:shift.shift_start_time+' - '+shift.shift_end_time,
                  shift_no:shift.shift_no,
                  alarm_type:alarm.present? ? alarm.alarm_type : 0,
                  alarm_number:alarm.present? ? alarm.alarm_no : 0,
                  alarm_message:alarm.present? ? alarm.message : 0,
                  #emergency:alarm.present? ?alarm.emergency : 0,
                  machine_name:alarm.present? ? alarm.machine.machine_name : 0,
                  machine_type:alarm.present? ? alarm.machine.machine_type : 0,
                  operator_name:operator_name,
                  operator_id:operator_id,
                  duration:Time.at(duration).utc.strftime("%H:%M:%S")
                  }
               end
              end
           end
        end

      elsif params[:report_type] == "Operatorwise"
          date_include_operator=OperatorMappingAllocation.where(:date=>params[:start_date].to_date..params[:end_date].to_date,:operator_id=>  params[:operator_id])  
          machines.map do | machine|
          date_include_operator.map do |operator_mapping_row| 
              shift_transaction= operator_mapping_row.operator_allocation.shifttransaction   
              machine_row = operator_mapping_row.operator_allocation.machine
                if shift_transaction.shift_start_time.include?("PM") && shift_transaction.shift_end_time.include?("AM")
                start_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_start_time).to_time
                end_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_end_time).to_time+1.day        
                elsif shift_transaction.shift_start_time.include?("AM") && shift_transaction.shift_end_time.include?("AM")
                start_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_start_time).to_time+1.day
                end_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_end_time).to_time+1.day
                else
                start_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_start_time).to_time
                end_time = ((operator_mapping_row.date).strftime("%F")+" "+shift_transaction.shift_end_time).to_time        
                end
                end_time_for_ideal = Time.now < end_time ? Time.now : end_time
                total_shift_time_available = Time.parse(shift_transaction.actual_working_hours).seconds_since_midnight
              
                machine.alarm_histories.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id).map do | alarm|
                  #operator_name = shift.operator_allocations.where(machine_id:machine.id).last.nil? ?  "Not Assigned" : shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.present? ? shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.operator.operator_name : "Not Assigned"
                  #operator_id = shift.operator_allocations.where(machine_id:machine.id).last.nil? ?  "Not Assigned" : shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.present? ? shift.operator_allocations.where(machine_id:machine.id).last.operator_mapping_allocations.where(:date=>date.to_date).last.operator.operator_spec_id : "Not Assigned"
                  update=alarm.updated_at.strftime("%H:%M:%S")
                 create=alarm.created_at.strftime("%H:%M:%S")
                duration =  update.to_time - create.to_time
                  data ={
                  :date=>(operator_mapping_row.date).strftime("%F"),
                  :time=>shift_transaction.shift_start_time+' - '+shift_transaction.shift_end_time,
                  :shift_no =>shift_transaction.shift_no,
                  alarm_type:alarm.present? ? alarm.alarm_type : 0,
                  alarm_number:alarm.present? ? alarm.alarm_number : 0,
                  alarm_message:alarm.present? ? alarm.alarm_message : 0,
                  #emergency:alarm.present? ?alarm.emergency : 0,
                  machine_name:alarm.present? ? alarm.machine.machine_name : 0,
                  machine_type:alarm.present? ? alarm.machine.machine_type : 0,
                  operator_name:operator_mapping_row.operator.operator_name,
                  operator_id:operator_mapping_row.operator.operator_spec_id,
                  duration:Time.at(duration).utc.strftime("%H:%M:%S")
                  }
                end
              end
          end
      end
  end
























  def self.alarm_report_num(start_date, end_date, tenant)
  
    @alldata = []
    #start_date.to_date..end_date.to_date.map(&:to_s).map do |date|
    dates = start_date.to_date..end_date.to_date
    dates.map(&:to_s).map do |date|
    tenant = Tenant.find(tenant)
    machines = tenant.machines.where(controller_type: 1)
    shifts = tenant.shift.shifttransactions
    #shift = tenant.shift.shifttransactions.where(shift_no: shift_no).last
    shifts.each do |shift|
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
      machines.order(:id).map do |mac|
        alarms = mac.alarm_tests.where("time >= ? AND time <= ?",start_time.utc.to_time,end_time.utc.to_time).order(:id)
 
        if shift.operator_allocations.where(machine_id:mac.id).last.nil?
        operator_id = nil
        target = 0
      else
        if shift.operator_allocations.where(machine_id:mac.id).present?
        shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
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
      
      if alarms.present?
        alarms.each do |io|
          @alldata << [
              date,  
              shift.shift_no,  
              io.time,
              io.message, 
              io.alarm_no,  
              io.alarm_type,
              io.axis_no,
             # io.category,
              0,
              io.machine_id,  
              shift.shift.id,  
              tenant.id,
              operator_id
           ]
        end
      end
      end
      end
      end
     

      if @alldata.present?
        @alldata.each do |data|
          if AlarmReport.where(date: data[0], shift_no: data[1], alarm_time: data[2], message:data[3], alarm_no: data[4], alarm_type: data[5], machine_id: data[8], shift_id: data[9], operator_id: data[11]).present?
            puts "Go Go"
          else
            AlarmReport.create(date: data[0], shift_no: data[1], alarm_time: data[2], message:data[3], alarm_no: data[4], alarm_type: data[5], axis_no: data[6], category: data[7], machine_id: data[8], shift_id: data[9], tenant_id: data[10], operator_id: data[11])
          end 
        end
      end
  end




















end
