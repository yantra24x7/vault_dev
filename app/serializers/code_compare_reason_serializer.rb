class CodeCompareReasonSerializer < ActiveModel::Serializer
  attributes :id, :user_name, :machine_name, :description, :create_date, :old_revision_no, :new_revision_no, :file_name
  # has_one :user
  # has_one :tenant
  # has_one :machine

#  def user_name
 #      byebug
  #      if object.user.present?
 # 	"#{object.user.first_name} #{object.user.last_name}"
 #       else
 #       "-"
 #       end
 # end

  def machine_name
  	object.machine.machine_name
  end
end

