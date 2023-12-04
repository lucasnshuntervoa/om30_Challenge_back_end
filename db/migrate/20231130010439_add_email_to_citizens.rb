# frozen_string_literal: true

class AddEmailToCitizens < ActiveRecord::Migration[7.0]
  def change
    add_column :citizens, :email, :string
  end
end
