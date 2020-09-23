class MachineSerializer < ActiveModel::Serializer
  attributes :id,:machine_name, :machine_model, :machine_serial_no, :tenant_id, :customer_name, :machine_type,:machine_ip,:unit,:device_id, :controller_type


 def customer_name
  	object.tenant.tenant_name
  end
end
