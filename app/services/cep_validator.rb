# frozen_string_literal: true

# app/services/cep_validator.rb

require 'net/http'
require 'json'

class CepValidator
  def self.valid_cep?(cep)
    url = URI("https://viacep.com.br/ws/#{cep}/json/")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)
    !data['erro']
  rescue StandardError
    false
  end
end
