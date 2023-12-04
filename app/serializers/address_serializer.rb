# frozen_string_literal: true

class AddressSerializer < ActiveModel::Serializer
  attributes :id, :street, :city, :state, :complement, :ibge_code
end
