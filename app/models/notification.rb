class Notification < ApplicationRecord
  belongs_to :machine_log, :optional=>true
end
