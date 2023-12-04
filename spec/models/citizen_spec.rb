# frozen_string_literal: true

# spec/models/citizen_spec.rb

require 'rails_helper'

RSpec.describe Citizen, type: :model do
  let(:photo_directory) { Rails.root.join('spec', 'fixtures', 'files', 'sample_photos') }
  let(:photo_files) { Dir.children(photo_directory) }
  let(:photo_path) { File.join(photo_directory, photo_files.sample) }

  let(:valid_attributes) do
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

  it 'is valid with proper attributes' do
    citizen = Citizen.new(valid_attributes)
    expect(citizen).to be_valid
  end

  it 'is not valid without a name' do
    citizen = Citizen.new(valid_attributes.merge(name: nil))
    expect(citizen).not_to be_valid
  end

  it 'is not valid with a name of incorrect format' do
    citizen = Citizen.new(valid_attributes.merge(name: 'John123'))
    expect(citizen).not_to be_valid
  end

  it 'is valid with a valid cpf' do
    citizen = Citizen.new(valid_attributes.merge(cpf: '15124133724')) # Substitua 'valid_cpf' por um CPF válido para testes
    expect(citizen).to be_valid
  end

  it 'is not valid with an invalid cpf' do
    citizen = Citizen.new(valid_attributes.merge(cpf: 'invalid_cpf'))
    expect(citizen).not_to be_valid
  end

  it 'is valid with a valid telephone format' do
    citizen = Citizen.new(valid_attributes)
    expect(citizen).to be_valid
  end

  it 'is not valid with an invalid telephone format' do
    citizen = Citizen.new(valid_attributes.merge(telephone: '123456'))
    expect(citizen).not_to be_valid
  end

  it 'is not valid with a future date of birth' do
    citizen = Citizen.new(valid_attributes.merge(date_of_birth: Date.tomorrow))
    expect(citizen).not_to be_valid
  end

  it 'validates CPF format' do
    citizen = Citizen.new(valid_attributes)

    # Chame o método cpf_valid
    citizen.cpf_valid

    # Verifique se não há erros no objeto Citizen
    expect(citizen.errors[:cpf]).to be_empty
  end

  it 'detects invalid CPF format' do
    citizen = Citizen.new(valid_attributes.merge(cpf: '1234567890')) # CPF inválido

    # Chame o método cpf_valid
    citizen.cpf_valid

    # Verifique se há um erro no objeto Citizen relacionado ao CPF
    expect(citizen.errors[:cpf]).to include('não é válido')
  end

  describe '#valid_date_of_birth' do
    let(:citizen) { Citizen.new(valid_attributes) }

    context 'when date_of_birth is in the future' do
      it 'is not valid' do
        citizen.date_of_birth = Date.tomorrow
        citizen.valid_date_of_birth
        expect(citizen.errors[:date_of_birth]).to include('não pode estar no futuro')
      end
    end

    context 'when date_of_birth is more than 120 years ago' do
      it 'is not valid' do
        citizen.date_of_birth = 121.years.ago
        citizen.valid_date_of_birth
        expect(citizen.errors[:date_of_birth]).to include('é improvavelmente antiga')
      end
    end

    context 'when date_of_birth is a valid date' do
      it 'is valid' do
        citizen.date_of_birth = 30.years.ago
        citizen.valid_date_of_birth
        expect(citizen.errors[:date_of_birth]).to be_empty
      end
    end
  end

  describe '#telephone_format' do
    let(:citizen) { Citizen.new(valid_attributes) }

    context 'when telephone is in the correct format' do
      it 'is valid' do
        citizen.telephone = '+55-21-123456789' # Exemplo de formato válido
        citizen.telephone_format
        expect(citizen.errors[:telephone]).to be_empty
      end
    end

    context 'when telephone is in the incorrect format' do
      it 'is not valid with missing country code' do
        citizen.telephone = '21-123456789' # Sem código do país
        citizen.telephone_format
        expect(citizen.errors[:telephone]).to include('formato inválido')
      end

      it 'is not valid with missing area code' do
        citizen.telephone = '+55-123456789' # Sem código de área
        citizen.telephone_format
        expect(citizen.errors[:telephone]).to include('formato inválido')
      end

      it 'is not valid with incorrect number of digits' do
        citizen.telephone = '+55-21-1234567' # Número de dígitos incorreto
        citizen.telephone_format
        expect(citizen.errors[:telephone]).to include('formato inválido')
      end

      it 'is not valid with non-numeric characters' do
        citizen.telephone = '+55-21-ABCDEF123' # Caracteres não numéricos
        citizen.telephone_format
        expect(citizen.errors[:telephone]).to include('formato inválido')
      end
    end
  end

  describe '#valid_cns' do
    let(:citizen) { Citizen.new(valid_attributes) }

    context 'when CNS is valid' do
      it 'does not add error for a regular valid CNS' do
        citizen.cns = '962990631662897' # Substitua com um CNS válido regular
        citizen.valid_cns
        expect(citizen.errors[:cns]).to be_empty
      end

      it 'does not add error for a special valid CNS' do
        citizen.cns = '00000000000123' # Substitua com um CNS válido especial
        citizen.valid_cns
        expect(citizen.errors[:cns]).to be_empty
      end
    end

    context 'when CNS is invalid' do
      it 'adds an error for invalid format' do
        citizen.cns = 'invalidcns'
        citizen.valid_cns
        expect(citizen.valid_cns).to be false
      end

      it 'adds an error for incorrect length' do
        citizen.cns = '1234567890'
        citizen.valid_cns
        expect(citizen.valid_cns).to be false
      end

      it 'adds an error for invalid CNS number' do
        citizen.cns = '123456789012346' # Um número CNS inválido
        citizen.valid_cns
        expect(citizen.valid_cns).to be false
      end
    end
  end

  describe '#send_create_notification_by_email' do
    let(:kafka) { instance_double(Kafka::Client) }
    let(:citizen) { Citizen.new(valid_attributes) } # Adicione esta linha

    before do
      allow(Kafka).to receive(:new).and_return(kafka)
      allow(kafka).to receive(:deliver_message)
    end

    it 'sends a create notification message to Kafka' do
      citizen.send_create_notification_by_email # Corrija a chamada do método aqui

      expect(kafka).to have_received(:deliver_message) do |json_str, options|
        expect(options[:topic]).to eq 'email-citizen-create'
        json_data = JSON.parse(json_str)
        expect(json_data).to include('email', 'name', 'last_name', 'cns', 'date_of_birth', 'telephone', 'status', 'cpf')
      end
    end
  end

  describe '#send_update_notification_by_email' do
    let(:citizen) { FactoryBot.create(:citizen) } # Substitua por sua factory do Citizen
    let(:kafka) { instance_double(Kafka::Client) }

    before do
      allow(Kafka).to receive(:new).and_return(kafka)
      allow(kafka).to receive(:deliver_message)
    end

    it 'sends an update notification message to Kafka' do
      citizen.send_update_notification_by_email
      expect(kafka).to have_received(:deliver_message).with(instance_of(String), topic: 'email-citizen-update')
    end
  end

  describe '#send_create_notification_by_sms' do
    let(:citizen) { FactoryBot.create(:citizen) } # Substitua por sua factory do Citizen
    let(:kafka) { instance_double(Kafka::Client) }

    before do
      allow(Kafka).to receive(:new).and_return(kafka)
      allow(kafka).to receive(:deliver_message)
    end

    it 'sends a create SMS notification message to Kafka' do
      citizen.send_create_notification_by_sms
      expect(kafka).to have_received(:deliver_message).with(instance_of(String), topic: 'sms-citizen-create')
    end
  end

  describe '#send_update_notification_by_sms' do
    let(:kafka) { instance_double(Kafka::Client) }
    let(:citizen) { Citizen.new(valid_attributes) } # Certifique-se de que valid_attributes esteja definido corretamente

    before do
      allow(Kafka).to receive(:new).and_return(kafka)
      allow(kafka).to receive(:deliver_message)
    end

    it 'sends an update SMS notification message to Kafka' do
      citizen.send_update_notification_by_sms

      expect(kafka).to have_received(:deliver_message) do |json_str, options|
        expect(options[:topic]).to eq 'sms-citizen-update'
        json_data = JSON.parse(json_str)
        expect(json_data).to include('email', 'name', 'last_name', 'cns', 'date_of_birth', 'telephone', 'status', 'cpf')
      end
    end
  end
end
