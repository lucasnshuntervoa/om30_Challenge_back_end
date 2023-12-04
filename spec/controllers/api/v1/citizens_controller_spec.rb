# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Citizens', type: :request do
  describe 'GET /api/v1/citizens' do
    before do
      create_list(:citizen, 10)
      get api_v1_citizens_path
    end

    it 'returns a success response' do
      expect(response).to be_successful
    end

    it 'returns the correct number of citizens' do
      expect(JSON.parse(response.body).size).to eq(10)
    end
  end

  describe 'GET /api/v1/citizens/:id' do
    let(:citizen) { create(:citizen) }

    before do
      get api_v1_citizen_path(citizen)
    end

    it 'returns a success response' do
      expect(response).to be_successful
    end

    it 'returns the requested citizen' do
      expect(JSON.parse(response.body)['id']).to eq(citizen.id)
    end
  end

  describe 'POST /api/v1/citizens' do
    context 'quando cria um citizen sem endereço' do
      let(:valid_attributes) { attributes_for(:citizen) }

      it 'cria um novo Citizen' do
        expect do
          post api_v1_citizens_path, params: { citizen: valid_attributes }
        end.to change(Citizen, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'quando cria um citizen com endereço' do
      let(:valid_attributes_with_address) do
        attributes_for(:citizen).merge(addresses_attributes: [attributes_for(:address)])
      end

      it 'cria um novo Citizen com Address' do
        expect do
          post api_v1_citizens_path, params: { citizen: valid_attributes_with_address }
        end.to change(Citizen, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(Citizen.last.addresses.count).to eq(1)
      end
    end
  end

  describe 'PUT /api/v1/citizens/:id' do
    let(:citizen) { create(:citizen) }

    context 'quando atualiza um citizen sem endereço' do
      let(:new_attributes) { { name: 'Updated Name' } }

      it 'atualiza o citizen solicitado' do
        put api_v1_citizen_path(citizen), params: { citizen: new_attributes }
        citizen.reload
        expect(citizen.name).to eq('Updated Name')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'quando atualiza um citizen e adiciona um endereço' do
      let(:new_attributes_with_address) do
        { addresses_attributes: [attributes_for(:address)] }
      end

      it 'atualiza o citizen e adiciona um novo endereço' do
        expect(citizen.addresses.count).to eq(0)

        put api_v1_citizen_path(citizen), params: { citizen: new_attributes_with_address }
        citizen.reload

        expect(citizen.addresses.count).to eq(1)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /api/v1/citizens' do
    context 'quando cria um citizen com uma foto' do
      let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/user.jpeg'), 'image/jpeg') }
      let(:valid_attributes_with_photo) { attributes_for(:citizen).merge(photo: file) }

      it 'cria um novo Citizen com uma foto e mocka o salvamento no S3' do
        expect do
          post api_v1_citizens_path, params: { citizen: valid_attributes_with_photo }
        end.to change(Citizen, :count).by(1)

        expect(response).to have_http_status(:created)
        last_citizen = Citizen.last
        expect(last_citizen.photo).to be_attached
        s3_url = "http://s3.sa-east-1.amazonaws.com/om30development/#{last_citizen.photo.blob.key}"
        allow(Rails.application.routes.url_helpers).to receive(:url_for).with(last_citizen.photo).and_return(s3_url)

        expect(Rails.application.routes.url_helpers.url_for(last_citizen.photo)).to eq(s3_url)
      end
    end
  end
end
