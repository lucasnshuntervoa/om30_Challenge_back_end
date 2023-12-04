# frozen_string_literal: true

class CitizenSerializer < ActiveModel::Serializer
  attributes :id, :name, :last_name, :cpf, :status, :cns, :date_of_birth, :status, :cpf, :telephone, :email,
             :citizen_photo
  has_many :addresses
end
