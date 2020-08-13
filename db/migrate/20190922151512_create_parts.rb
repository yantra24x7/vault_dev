class CreateParts < ActiveRecord::Migration[5.0]
  def change
    create_table :parts do |t|
      t.date :date
      t.string :shift_no
      t.string :part
      t.string :program_number
      t.string :cycle_time
      t.string :cutting_time
      t.string :cycle_st_to_st
      t.string :cycle_stop_to_stop
      t.datetime :time
      t.references :shifttransaction, foreign_key: true
      t.references :machine, foreign_key: true
      t.boolean :is_active
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
