# frozen_string_literal: true

# spec/models/address_spec.rb

require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:photo_directory) { Rails.root.join('spec', 'fixtures', 'files', 'sample_photos') }
  let(:photo_files) { Dir.children(photo_directory) }
  let(:photo_path) { File.join(photo_directory, photo_files.sample) }

  let(:valid_attributes_for_citizen) do
    {
      name: 'John',
      last_name: 'Doe',
      cpf: '15124133724', # Use um gerador de CPF para obter um valor válido
      cns: '962990631662897', # Valor fictício, substitua conforme necessário
      date_of_birth: '1980-01-01',
      telephone: '+55-21-12345678',
      email: 'john@example.com',
      status: :active,
      photo: Rack::Test::UploadedFile.new(photo_path, 'image/jpeg')
    }
  end

  let(:citizen) { Citizen.create(valid_attributes_for_citizen) }
  let(:valid_attributes) do
    {
      postal_code: '79008450',
      street: 'Rua Exemplo',
      neighborhood: 'Bairro Exemplo',
      city: 'Cidade Exemplo',
      state: 'MS', # Usando uma abreviação válida de dois caracteres
      citizen:
    }
  end

  context 'validations' do
    it 'is valid with valid attributes' do
      address = Address.new(valid_attributes)
      expect(address).to be_valid
    end

    it 'is not valid without a postal_code' do
      address = Address.new(valid_attributes.except(:postal_code))
      expect(address).not_to be_valid
    end

    # Repita para street, neighborhood, city, state

    it 'is not valid with an invalid postal_code' do
      address = Address.new(valid_attributes.merge(postal_code: 'invalid'))
      expect(address).not_to be_valid
    end

    it 'is valid with a correctly formatted city' do
      address = Address.new(valid_attributes.merge(city: 'City-Name'))
      expect(address).to be_valid
    end

    it 'is not valid with an incorrectly formatted city' do
      address = Address.new(valid_attributes.merge(city: 'City123'))
      expect(address).not_to be_valid
    end

    it 'is valid with a correctly formatted state' do
      address = Address.new(valid_attributes.merge(state: 'ES'))
      expect(address).to be_valid
    end

    it 'is not valid with an incorrectly formatted state' do
      address = Address.new(valid_attributes.merge(state: '1State'))
      expect(address).not_to be_valid
    end
  end
end
