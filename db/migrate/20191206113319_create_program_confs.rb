class CreateProgramConfs < ActiveRecord::Migration[5.0]
  def change
    create_table :program_confs do |t|
      t.string :ip
      t.string :user_name
      t.string :pass
      t.string :master_location
      t.string :slave_location
      t.references :machine, foreign_key: true

      t.timestamps
    end
  end
end
