# frozen_string_literal: true

require 'faker'
def generate_valid_cns
  def is_valid_cns(cns)
    if cns[0..10] == '00000000000' && %w[1 2].include?(cns[11])
      sum = cns.chars.each_with_index.sum { |char, index| char.to_i * (15 - index) }
    else
      weights = [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
      sum = cns.chars.map(&:to_i).zip(weights).sum { |a, b| a * b }
    end
    (sum % 11).zero?
  end

  loop do
    cns_candidate = Array.new(15) { rand(0..9) }.join
    return cns_candidate if is_valid_cns(cns_candidate)
  end
end

# Método para gerar um número de telefone válido no formato de celular
def generate_valid_telephone
  country_code = rand(10..99).to_s
  area_code = rand(10..99).to_s
  phone_number = rand(rand(1..2) == 8 ? 10_000_000..99_999_999 : 100_000_000..999_999_999).to_s

  "+#{country_code}-#{area_code}-#{phone_number}"
end

def valid_brazilian_zip_code
  valid_ceps = [
    '01001-000', # CEP de um local público em São Paulo
    '20031-144', # CEP de um local público no Rio de Janeiro
    '30130-110' # CEP de um local público em Belo Horizonte
  ]

  valid_ceps.sample # Retorna um CEP aleatório do array
end

def generate_valid_cpf
  CPF.generate(true) # O argumento `true` gera um CPF formatado
end

FactoryBot.define do
  factory :citizen do
    name { 'John' }
    last_name { 'Doe' }
    cpf { generate_valid_cpf } # Usando Faker para CPF
    cns { generate_valid_cns }
    date_of_birth { '1980-01-01' }
    telephone { generate_valid_telephone }
    email { Faker::Internet.email } # Usando Faker para email
    status { :active }
    photo { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/user.jpeg'), 'image/jpeg') }
  end
end
