class ProgramConf < ApplicationRecord
  belongs_to :machine
  validates :machine_id, presence: true, uniqueness: true
end
