class UserSerializer < ActiveModel::Serializer
  attributes :id ,:first_name,:last_name,:email_id,:phone_number,:remarks,:usertype_id,:approval_id,:tenant,:role_name,:isactive
  #belongs_to :tenant
  
  def role_name
   Role.find(object.role_id).role_name if object.role_id.present?
  end
end
