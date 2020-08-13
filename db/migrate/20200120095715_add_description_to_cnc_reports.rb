class AddDescriptionToCncReports < ActiveRecord::Migration[5.0]
  def change
    add_column :cnc_reports, :parts_data, :json
    add_column :cnc_hour_reports, :parts_data, :json
    add_index :cnc_reports, :date
    add_index :cnc_hour_reports, :date
  end
end
