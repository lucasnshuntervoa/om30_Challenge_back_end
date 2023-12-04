# frozen_string_literal: true

class CreateCitizens < ActiveRecord::Migration[7.0]
  def change
    create_table :citizens do |t|
      t.string :name
      t.string :last_name
      t.string :cpf
      t.string :cns
      t.date :date_of_birth
      t.string :telephone
      t.integer :status

      t.timestamps
    end
  end
end
