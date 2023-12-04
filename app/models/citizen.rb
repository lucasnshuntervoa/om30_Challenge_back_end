# frozen_string_literal: true

class Citizen < ApplicationRecord
  has_one_attached :photo
  has_many :addresses, dependent: :destroy
  accepts_nested_attributes_for :addresses

  enum status: { active: 0, inactive: 1 }

  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :name, :last_name, presence: true,
                             format: { with: /\A[\p{L}\s]+\z/, message: 'somente permite letras e espaços' },
                             length: { minimum: 2, maximum: 50 }
  validates :cns, presence: true, uniqueness: { message: 'já está em uso' }
  validates :date_of_birth, presence: true
  validates :status, presence: true
  validates :cpf, presence: true, uniqueness: { message: 'já está em uso' }
  validates :telephone, presence: true, uniqueness: { message: 'já está em uso' }
  validates :email, presence: true, uniqueness: { message: 'já está em uso' },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :photo, presence: true

  validate :cpf_valid
  validate :valid_date_of_birth
  validate :telephone_format
  validate :valid_cns

  before_save :normalize_name
  after_create :send_create_notification_by_email
  after_update :send_update_notification_by_email
  after_create :send_update_notification_by_sms
  after_update :send_create_notification_by_sms

  def thumbnail
    photo.variant(resize: '100x100').processed
  end

  def medium_size
    photo.variant(resize: '500x500').processed
  end

  def cpf_valid
    errors.add(:cpf, 'não é válido') unless CPF.valid?(cpf)
  end

  def valid_date_of_birth
    return if date_of_birth.blank?

    if date_of_birth > Date.today
      errors.add(:date_of_birth, 'não pode estar no futuro')
    elsif date_of_birth < 120.years.ago
      errors.add(:date_of_birth, 'é improvavelmente antiga')
    end
  end

  def telephone_format
    return if telephone.match?(/\A\+\d{2}-\d{2}-\d{8,9}\z/)

    errors.add(:telephone, 'formato inválido')
  end

  def valid_cns
    # Verifica se o formato do CNS é válido
    return false unless cns.match?(/\A\d{15}\z/)

    # Calcula a soma com base no padrão do CNS
    sum = if cns[0..10] == '00000000000' && %w[1 2].include?(cns[11])
            cns.chars.each_with_index.sum do |char, index|
              char.to_i * (15 - index)
            end
          else
            weights = [15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
            cns.chars.map(&:to_i).zip(weights).sum { |a, b| a * b }
          end

    # Adiciona o erro se a validação falhar
    if (sum % 11).zero?
      true
    else
      errors.add(:cns, 'não é válido')
      false
    end
  end

  def send_create_notification_by_email
    
    message = {
      email:,
      name:,
      status:,
      last_name:,
      cns:,
      date_of_birth:,
      telephone:,
      status:,
      cpf:
    }.to_json
    kafka = Kafka.new(['localhost:9092'])
    kafka.deliver_message(message, topic: 'email-citizen-create')
  end

  def send_update_notification_by_email
    
    message = {
      email:,
      name:,
      status:,
      last_name:,
      cns:,
      date_of_birth:,
      telephone:,
      status:,
      cpf:
    }.to_json
    kafka = Kafka.new(['localhost:9092'])
    kafka.deliver_message(message, topic: 'email-citizen-update')
  end

  def send_create_notification_by_sms
   
    message = {
      email:,
      name:,
      status:,
      last_name:,
      cns:,
      date_of_birth:,
      telephone:,
      cpf:
    }.to_json

    kafka = Kafka.new(['localhost:9092'])
    kafka.deliver_message(message, topic: 'sms-citizen-create')
  end

  def send_update_notification_by_sms
    
    message = {
      email:,
      name:,
      status:,
      last_name:,
      cns:,
      date_of_birth:,
      telephone:,
      cpf:
    }.to_json

    kafka = Kafka.new(['localhost:9092'])
    kafka.deliver_message(message, topic: 'sms-citizen-update')
  end

  def citizen_photo
    if photo.present?
      photo.url
    else
      'A foto do cidadão não está disponível no momento.'
    end
  end

  private

  def normalize_name
    self.name = name.squish.titleize
    self.last_name = last_name.squish.titleize
  end
end
