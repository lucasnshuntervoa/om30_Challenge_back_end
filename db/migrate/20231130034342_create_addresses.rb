# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.string :postal_code
      t.string :street
      t.string :complement
      t.string :neighborhood
      t.string :city
      t.string :state
      t.string :ibge_code
      t.references :citizen, null: false, foreign_key: true

      t.timestamps
    end
  end
end
