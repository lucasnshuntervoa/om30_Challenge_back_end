# frozen_string_literal: true

# db/seeds.rb

require 'faker'
require 'cpf_cnpj'

# Método para gerar CPFs válidos
def generate_valid_cpf
  loop do
    cpf = CPF.generate # Gera um CPF aleatório
    return cpf if CPF.valid?(cpf)
  end
end

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

# Diretório onde as imagens de amostra estão armazenadas
photo_directory = Rails.root.join('public', 'sample_photos')
photo_files = Dir.children(photo_directory)

# Limpar registros existentes (opcional)
Citizen.destroy_all

# Criar cidadãos falsos

puts "Gerando cidadão #{0 + 1}"
citizen = Citizen.new(
  name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  cpf: generate_valid_cpf,
  cns: generate_valid_cns, # Usamos o método para gerar CNS válido
  date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 80),
  telephone: generate_valid_telephone, # Usamos o método para gerar telefone válido
  email: Faker::Internet.email,
  status: %w[active inactive].sample
)

# Adicionando foto ao cidadão
photo_path = File.join(photo_directory, photo_files.sample)
citizen.photo.attach(io: File.open(photo_path), filename: File.basename(photo_path))

3.times do
  address = Address.new(
    citizen:,
    postal_code: valid_brazilian_zip_code, # Utiliza o método personalizado
    street: Faker::Address.street_name,
    neighborhood: Faker::Address.community,
    city: Faker::Address.city,
    state: 'SP',
    ibge_code: Faker::Number.number(digits: 7),
    complement: Faker::Lorem.sentence(word_count: 3)
  )

  if address.valid?
    address.save
  else
    puts "Falha ao criar endereço para cidadão #{0 + 1}:"
    address.errors.full_messages.each do |message|
      puts "- #{message}"
    end
  end
end

if citizen.valid?
  citizen.save
else
  puts "Falha ao criar cidadão #{0 + 1}:"
  citizen.errors.full_messages.each do |message|
    puts "- #{message}"
  end
end
