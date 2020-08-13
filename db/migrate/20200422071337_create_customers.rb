class CreateCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.string :company_name
      t.string :contact_person
      t.string :contact_no
      t.string :address_line1
      t.string :address_line2
      t.string :city
      t.string :state
      t.string :country
      t.string :pincode
      t.string :customer_email
      t.references :tenant, foreign_key: true

      t.timestamps
    end
  end
end
