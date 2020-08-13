class AlarmReportSerializer < ActiveModel::Serializer
  attributes :id, :date, :shift_no, :alarm_time, :message, :alarm_no, :alarm_type, :axis_no, :category, :machine_id, :shift_id, :tenant_id, :operator_id, :machine_name, :operator_name 
def machine_name
  object.machine.machine_name
end

def operator_name
  if object.operator_id == nil
	"Not Assigned" 
  else
	object.operator.operator_name
  end
end

def date
   object.date.strftime("%d-%m-%Y")
end



def message
	
  if object.message == ''
	"-" 
  else
	object.message
  end	
	
end
end
