# frozen_string_literal: true

# spec/factories/addresses.rb
FactoryBot.define do
  factory :address do
    postal_code { '79008450' }
    street { 'Rua Exemplo' }
    neighborhood { 'Bairro Exemplo' }
    city { 'Cidade Exemplo' }
    state { 'MS' }
    association :citizen
  end
end
