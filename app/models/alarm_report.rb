class AlarmReport < ApplicationRecord
  belongs_to :machine
  belongs_to :shift
  belongs_to :tenant
  belongs_to :operator
end
