class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :company_name, :contact_person, :contact_no, :address_line1, :address_line2, :city, :state, :country, :pincode, :customer_email
  has_one :tenant
end
