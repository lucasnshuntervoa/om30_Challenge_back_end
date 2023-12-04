# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :citizen
  validates_presence_of :postal_code, :street, :neighborhood, :city, :state
  validate :cep_must_be_valid

  validates :city, format: { with: /\A[a-zA-Z\s-]+\z/,
                             message: 'apenas permite letras, espaços e hifens' }

  validates :state, format: { with: /\A[A-Z\s-]{2,}\z/,
                              message: 'deve ser uma abreviação válida de dois ou palavra com mais caracteres' }

  def cep_must_be_valid
    if CepValidator.valid_cep?(postal_code)
      true
    else
      errors.add(:postal_code, 'não é válido')
      false
    end
  end
end
