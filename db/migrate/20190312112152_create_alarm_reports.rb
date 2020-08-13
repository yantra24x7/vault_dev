class CreateAlarmReports < ActiveRecord::Migration[5.0]
  def change
    create_table :alarm_reports do |t|
      t.date :date
      t.integer :shift_no
      t.datetime :alarm_time
      t.string :message
      t.string :alarm_no
      t.string :alarm_type
      t.string :axis_no
      t.string :category
      t.references :machine, foreign_key: true
      t.references :shift, foreign_key: true
      t.references :tenant, foreign_key: true
      t.references :operator, foreign_key: true

      t.timestamps
    end
  end
end
