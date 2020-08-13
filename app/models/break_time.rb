 require 'activerecord-import/base' 
class BreakTime < ApplicationRecord
  belongs_to :shifttransaction, -> { with_deleted }
  

  def self.active_import
    last_id = MachineLog.last
    data = ExternalMachineLog.where("id >? AND created_at <?", last_id,Date.yesterday.beginning_of_day - 1.day)
    byebug
   # data = ExternalMachineLog.first(100)
    #MachineDailyLog.import data
    puts "ok"
  end


 def self.active_import1
    last_id = MachineLog.last.id
 #   byebug
#    data = ExternalMachineLog.where("id >? AND created_at <?", last_id,Date.today.beginning_of_day - 1.days).first(400000)
     data = ExternalMachineLog.where("id >? AND created_at <?", last_id,Date.today.beginning_of_day).first(400000)
 #  byebug
    i = 0
    data.each_slice(6000) do |da|
      MachineLog.import da
      puts i+= 1
    end
    #data = ExternalMachineLog.first(100)
    #MachineDailyLog.import data
    puts "ok"
  end









 def self.parts_time3(machine_log, all_logs, shift_no, shift, date)
     @data = []
    machine_log1 = machine_log.reject{|i| i.machine_status == "" || i.machine_status.nil? || i.machine_status == 100 }  
    all_status = machine_log1.pluck(:machine_status)
    short_data = []
     if all_status.include?(3)
      machine_log1.each do |i|
      unless short_data.present?
        first_record = all_logs.find_index(i)
        prev_record = all_logs[first_record - 1]
        if i.parts_count == prev_record.parts_count && i.programe_number == prev_record.programe_number
          dd = []
          split_rec = all_logs.split(i)
          logs = split_rec.first.reverse!         
          logs.each_with_index do |k,index|
            unless dd.present?
              if k == logs[-1]
                dd << logs[-1]
              elsif k.parts_count != i.parts_count || k.programe_number != i.programe_number
                dd << logs[index - 1]
              else
                ##puts "okokokok"  
              end
            end  
          end
           
          short_data << [dd.first.created_at, dd.first.parts_count, dd.first.programe_number, dd.first.id]
        else
          short_data << [i.created_at, i.parts_count, i.programe_number, i.id]
        end    
      else     
        unless short_data[-1][1] == i.parts_count && short_data[-1][2] == i.programe_number
          short_data << [i.created_at, i.parts_count, i.programe_number, i.id]
        end
      end
    end
  end
  short_data.each_with_index do |val,index|
    if val == short_data[-1]
      last_rec = machine_log1.select{|a| a[:parts_count] == val[1] && a[:programe_number] == val[2]}.last
      last_rec_index = all_logs.find_index(last_rec)
      next_record = all_logs[last_rec_index + 1].present? ? all_logs[last_rec_index + 1] : last_rec  
      unless next_record.parts_count == last_rec.parts_count && next_record.programe_number == last_rec.programe_number 
        records = all_logs.select{|a| a.id >= val[3] && a.id < last_rec.id}
        if records.pluck(:machine_status).include?(3)
          p_first_run_rcd = records.select{|a| a[:machine_status] == 3 }.first
          p_last_run_rcd = records.select{|a| a[:machine_status] == 3 }.last
          p_next_rec = all_logs[all_logs.find_index(p_last_run_rcd)+1].present? ? all_logs[all_logs.find_index(p_last_run_rcd)+1]: p_last_run_rcd
          p_next_start = all_logs.select{|a| a[:id] > p_last_run_rcd.id && a[:machine_status] == 3}.first.present? ? all_logs.select{|a| a[:id] > p_last_run_rcd.id && a[:machine_status] == 3}.first : machine_log1.select{|a| a[:id] >= p_last_run_rcd.id}.first
          cyls = []    
          cyls << p_last_run_rcd.run_time.to_i * 60 + p_last_run_rcd.run_second.to_i/1000
          cyls << p_next_rec.run_time.to_i * 60 + p_next_rec.run_second.to_i/1000
          cycle_time = [{:program_number=>val[2], :cycle_time=>cyls.max, :parts_count=>val[1]}] 
          cutting_time = (p_last_run_rcd.total_cutting_time.to_i * 60 + p_last_run_rcd.total_cutting_second.to_i/1000) - (p_first_run_rcd.total_cutting_time.to_i * 60 + p_first_run_rcd.total_cutting_second.to_i/1000)
          cycle_st_to_st = p_next_start.created_at - p_first_run_rcd.created_at
          cycle_sp_to_st = p_next_start.created_at - p_last_run_rcd.created_at
          @data << Part.new(date: date, shift_no: shift_no, part: val[1], program_number: val[2], cycle_time:cycle_time ,cutting_time: cutting_time, cycle_st_to_st: cycle_st_to_st, cycle_stop_to_stop: cycle_sp_to_st, time: p_last_run_rcd.created_at, shifttransaction_id: shift, machine_id: machine_log.first.machine_id)
        end
      end
    elsif val == short_data[0]
      records = all_logs.select{|a| a.id >= val[3] && a.id < short_data[index + 1][3]}
      if records.pluck(:machine_status).include?(3)
        p_first_run_rcd = records.select{|a| a[:machine_status] == 3 }.first
        p_last_run_rcd = records.select{|a| a[:machine_status] == 3 }.last
        p_next_rec = all_logs[all_logs.find_index(p_last_run_rcd)+1].present? ? all_logs[all_logs.find_index(p_last_run_rcd)+1] : p_last_run_rcd
        p_next_start = machine_log1.select{|a| a[:id] >= short_data[index + 1][3] && a[:machine_status] == 3}.first.present? ? machine_log1.select{|a| a[:id] >= short_data[index + 1][3] && a[:machine_status] == 3}.first : machine_log1.select{|a| a[:id] >= short_data[index + 1][3]}.first
        cyls = []    
        cyls << p_last_run_rcd.run_time.to_i * 60 + p_last_run_rcd.run_second.to_i/1000
        cyls << p_next_rec.run_time.to_i * 60 + p_next_rec.run_second.to_i/1000
        cycle_time = [{:program_number=>val[2], :cycle_time=>cyls.max, :parts_count=>val[1]}] 
        cutting_time = (p_last_run_rcd.total_cutting_time.to_i * 60 + p_last_run_rcd.total_cutting_second.to_i/1000) - (p_first_run_rcd.total_cutting_time.to_i * 60 + p_first_run_rcd.total_cutting_second.to_i/1000)
        cycle_st_to_st = p_next_start.created_at - p_first_run_rcd.created_at
        cycle_sp_to_st = p_next_start.created_at - p_last_run_rcd.created_at
        @data << Part.new(date: date, shift_no: shift_no, part: val[1], program_number: val[2], cycle_time:cycle_time ,cutting_time: cutting_time, cycle_st_to_st: cycle_st_to_st, cycle_stop_to_stop: cycle_sp_to_st, time: p_last_run_rcd.created_at, shifttransaction_id: shift, machine_id: machine_log.first.machine_id)
        #date: nil, shift_no: nil, part: nil, program_number: nil, cycle_time: nil, cutting_time: nil, cycle_st_to_st: nil, cycle_stop_to_stop: nil, time: nil, shifttransaction_id: nil, machine_id: nil, is_active: nil, deleted_at: nil, created_at: nil, updated_at: nil
      end
    else
      records = machine_log1.select{|a| a.id >= val[3] && a.id < short_data[index + 1][3]}
      if records.pluck(:machine_status).include?(3)
        p_first_run_rcd = records.select{|a| a[:machine_status] == 3 }.first
        p_last_run_rcd = records.select{|a| a[:machine_status] == 3 }.last
        p_next_rec = machine_log[machine_log1.find_index(p_last_run_rcd)+1].present? ? machine_log[machine_log1.find_index(p_last_run_rcd)+1]: p_last_run_rcd
        p_next_start = machine_log1.select{|a| a[:id] >= short_data[index + 1][3] && a[:machine_status] == 3}.first.present? ? machine_log1.select{|a| a[:id] >= short_data[index + 1][3] && a[:machine_status] == 3}.first : p_last_run_rcd
        cyls = []    
        cyls << p_last_run_rcd.run_time.to_i * 60 + p_last_run_rcd.run_second.to_i/1000
        cyls << p_next_rec.run_time.to_i * 60 + p_next_rec.run_second.to_i/1000
        cycle_time = [{:program_number=>val[2], :cycle_time=>cyls.max, :parts_count=>val[1]}] 
        cutting_time = (p_last_run_rcd.total_cutting_time.to_i * 60 + p_last_run_rcd.total_cutting_second.to_i/1000) - (p_first_run_rcd.total_cutting_time.to_i * 60 + p_first_run_rcd.total_cutting_second.to_i/1000)
        cycle_st_to_st = p_next_start.created_at - p_first_run_rcd.created_at
        cycle_sp_to_st = p_next_start.created_at - p_last_run_rcd.created_at
        @data << Part.new(date: date, shift_no: shift_no, part: val[1], program_number: val[2], cycle_time:cycle_time ,cutting_time: cutting_time, cycle_st_to_st: cycle_st_to_st, cycle_stop_to_stop: cycle_sp_to_st, time: p_last_run_rcd.created_at, shifttransaction_id: shift, machine_id: machine_log.first.machine_id)
      end
    end
  end
  
 # ret = Part.import @data
  return @data

  end


  

   def self.parts_time_r3(machine_log, all_logs, shift_no, shift, date)
    @data = []
    machine_log1 = machine_log.reject{|i| i.machine_status == "" || i.machine_status.nil? || i.machine_status == 100 }  
    all_status = machine_log1.pluck(:machine_status)
    short_data = []

    if all_status.include?(3)
      machine_log1.each do |i|
      unless short_data.present?
        first_record = all_logs.find_index(i)
        prev_record = all_logs[first_record - 1]
        if i.parts_count == prev_record.parts_count && i.programe_number == prev_record.programe_number
          dd = []
          split_rec = all_logs.split(i)
          logs = split_rec.first.reverse!         
          logs.each_with_index do |k,index|
            unless dd.present?
              if k == logs[-1]
                dd << logs[-1]
              elsif k.parts_count != i.parts_count || k.programe_number != i.programe_number
                dd << logs[index - 1]
              else
                ##puts "okokokok"  
              end
            end  
          end
          short_data << [dd.first.created_at, dd.first.parts_count, dd.first.programe_number, dd.first.id]
        else
          short_data << [i.created_at, i.parts_count, i.programe_number, i.id]
        end    
      else     
        unless short_data[-1][1] == i.parts_count && short_data[-1][2] == i.programe_number
          short_data << [i.created_at, i.parts_count, i.programe_number, i.id]
        end
      end
    end
  end
    
   short_data.each_with_index do |val,index|
    if val == short_data[-1]
      last_rec = machine_log1.select{|a| a[:parts_count] == val[1] && a[:programe_number] == val[2]}.last
      last_rec_index = all_logs.find_index(last_rec)
      next_record = all_logs[last_rec_index + 1].present? ? all_logs[last_rec_index + 1] : last_rec  
      unless next_record.parts_count == last_rec.parts_count && next_record.programe_number == last_rec.programe_number 
        records = all_logs.select{|a| a.id >= val[3] && a.id < last_rec.id}
        if records.pluck(:machine_status).include?(3)
          p_first_run_rcd = records.select{|a| a[:machine_status] == 3 }.first
          p_last_run_rcd = records.select{|a| a[:machine_status] == 3 }.last
          p_next_rec = all_logs[all_logs.find_index(p_last_run_rcd)+1].present? ? all_logs[all_logs.find_index(p_last_run_rcd)+1]: p_last_run_rcd
          p_next_start = all_logs.select{|a| a[:id] > p_last_run_rcd.id && a[:machine_status] == 3}.first.present? ? all_logs.select{|a| a[:id] > p_last_run_rcd.id && a[:machine_status] == 3}.first : machine_log1.select{|a| a[:id] >= p_last_run_rcd.id}.first
          # cyls = []    
          # cyls << p_last_run_rcd.run_time.to_i * 60 + p_last_run_rcd.run_second.to_i/1000
          # cyls << p_next_rec.run_time.to_i * 60 + p_next_rec.run_second.to_i/1000
          cyls = p_last_run_rcd.created_at - p_first_run_rcd.created_at
          cycle_time = [{:program_number=>val[2], :cycle_time=>cyls, :parts_count=>val[1]}] 
          cutting_time = cyls#(p_last_run_rcd.total_cutting_time.to_i * 60 + p_last_run_rcd.total_cutting_second.to_i/1000) - (p_first_run_rcd.total_cutting_time.to_i * 60 + p_first_run_rcd.total_cutting_second.to_i/1000)
          
          cycle_st_to_st = p_next_start.created_at - p_first_run_rcd.created_at
          cycle_sp_to_st = p_next_start.created_at - p_last_run_rcd.created_at
          @data << Part.new(date: date, shift_no: shift_no, part: val[1], program_number: val[2], cycle_time:cycle_time ,cutting_time: cutting_time, cycle_st_to_st: cycle_st_to_st, cycle_stop_to_stop: cycle_sp_to_st, time: p_last_run_rcd.created_at, shifttransaction_id: shift, machine_id: machine_log.first.machine_id)
        end
      end
    elsif val == short_data[0]
      records = all_logs.select{|a| a.id >= val[3] && a.id < short_data[index + 1][3]}
      if records.pluck(:machine_status).include?(3)
        p_first_run_rcd = records.select{|a| a[:machine_status] == 3 }.first
        p_last_run_rcd = records.select{|a| a[:machine_status] == 3 }.last
        p_next_rec = all_logs[all_logs.find_index(p_last_run_rcd)+1].present? ? all_logs[all_logs.find_index(p_last_run_rcd)+1] : p_last_run_rcd
        p_next_start = machine_log1.select{|a| a[:id] >= short_data[index + 1][3] && a[:machine_status] == 3}.first.present? ? machine_log1.select{|a| a[:id] >= short_data[index + 1][3] && a[:machine_status] == 3}.first : machine_log1.select{|a| a[:id] >= short_data[index + 1][3]}.first
        
        # cyls = []    
        # cyls << p_last_run_rcd.run_time.to_i * 60 + p_last_run_rcd.run_second.to_i/1000
        # cyls << p_next_rec.run_time.to_i * 60 + p_next_rec.run_second.to_i/1000
        cyls = p_last_run_rcd.created_at - p_first_run_rcd.created_at
        cycle_time = [{:program_number=>val[2], :cycle_time=>cyls, :parts_count=>val[1]}] 
        cutting_time = cyls#(p_last_run_rcd.total_cutting_time.to_i * 60 + p_last_run_rcd.total_cutting_second.to_i/1000) - (p_first_run_rcd.total_cutting_time.to_i * 60 + p_first_run_rcd.total_cutting_second.to_i/1000)
        cycle_st_to_st = p_next_start.created_at - p_first_run_rcd.created_at
        cycle_sp_to_st = p_next_start.created_at - p_last_run_rcd.created_at
        @data << Part.new(date: date, shift_no: shift_no, part: val[1], program_number: val[2], cycle_time:cycle_time ,cutting_time: cutting_time, cycle_st_to_st: cycle_st_to_st, cycle_stop_to_stop: cycle_sp_to_st, time: p_last_run_rcd.created_at, shifttransaction_id: shift, machine_id: machine_log.first.machine_id)
        #date: nil, shift_no: nil, part: nil, program_number: nil, cycle_time: nil, cutting_time: nil, cycle_st_to_st: nil, cycle_stop_to_stop: nil, time: nil, shifttransaction_id: nil, machine_id: nil, is_active: nil, deleted_at: nil, created_at: nil, updated_at: nil
      end
    else
      records = machine_log1.select{|a| a.id >= val[3] && a.id < short_data[index + 1][3]}
      if records.pluck(:machine_status).include?(3)
        p_first_run_rcd = records.select{|a| a[:machine_status] == 3 }.first
        p_last_run_rcd = records.select{|a| a[:machine_status] == 3 }.last
        p_next_rec = machine_log[machine_log1.find_index(p_last_run_rcd)+1].present? ? machine_log[machine_log1.find_index(p_last_run_rcd)+1]: p_last_run_rcd
        p_next_start = machine_log1.select{|a| a[:id] >= short_data[index + 1][3] && a[:machine_status] == 3}.first.present? ? machine_log1.select{|a| a[:id] >= short_data[index + 1][3] && a[:machine_status] == 3}.first : p_last_run_rcd
        # cyls = []    
        # cyls << p_last_run_rcd.run_time.to_i * 60 + p_last_run_rcd.run_second.to_i/1000
        # cyls << p_next_rec.run_time.to_i * 60 + p_next_rec.run_second.to_i/1000
        cyls = p_last_run_rcd.created_at - p_first_run_rcd.created_at
        cycle_time = [{:program_number=>val[2], :cycle_time=>cyls, :parts_count=>val[1]}] 
        cutting_time = cyls#(p_last_run_rcd.total_cutting_time.to_i * 60 + p_last_run_rcd.total_cutting_second.to_i/1000) - (p_first_run_rcd.total_cutting_time.to_i * 60 + p_first_run_rcd.total_cutting_second.to_i/1000)
        cycle_st_to_st = p_next_start.created_at - p_first_run_rcd.created_at
        cycle_sp_to_st = p_next_start.created_at - p_last_run_rcd.created_at
        @data << Part.new(date: date, shift_no: shift_no, part: val[1], program_number: val[2], cycle_time:cycle_time ,cutting_time: cutting_time, cycle_st_to_st: cycle_st_to_st, cycle_stop_to_stop: cycle_sp_to_st, time: p_last_run_rcd.created_at, shifttransaction_id: shift, machine_id: machine_log.first.machine_id)
      end
    end
  end

  return @data
  end







  

end
