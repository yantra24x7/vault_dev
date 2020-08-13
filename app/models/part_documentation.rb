class PartDocumentation < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :machine
end
