class Part < ApplicationRecord
  serialize :cycle_time, Array
  belongs_to :shifttransaction
  belongs_to :machine
end
