class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
 # ActiveRecord::Base.establish_connection "#{Rails.env}".to_sym
end
