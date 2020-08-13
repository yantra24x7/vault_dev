class ProgramConfSerializer < ActiveModel::Serializer
  attributes :id, :ip, :master_location, :slave_location, :user_name, :pass

  has_one :machine
end
