# frozen_string_literal: true

require_relative 'config/environment'
require 'kafka'
require 'sendgrid-ruby'
include SendGrid

def send_email_on_citizen_create(data)
  from_email = SendGrid::Email.new(email: 'remetente@teste.com', name: 'Teste')
  to_email = SendGrid::Email.new(email: data['email'])
  subject = 'Bem-vindo à Aplicação om30'

  email_body = <<~EMAIL
    Olá #{data['name']}, seu registro foi criado na aplicação om30. Segue seus dados cadastrados:

    Nome: #{data['name']}
    Sobrenome: #{data['last_name']}
    E-mail: #{data['email']}
    CPF: #{data['cpf']}
    CNS: #{data['cns']}
    Data de Nascimento: #{data['date_of_birth']}
    Telefone: #{data['telephone']}
    Status: #{data['status']}
  EMAIL

  content = SendGrid::Content.new(type: 'text/plain', value: email_body)

  mail = SendGrid::Mail.new(from_email, subject, to_email, content)

  sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  response = sg.client.mail._('send').post(request_body: mail.to_json)
  puts response.status_code
  puts response.body
  puts response.headers
end

def send_email_on_citizen_update(data)
  from_email = SendGrid::Email.new(email: 'remetente@teste.com', name: 'Teste')
  to_email = SendGrid::Email.new(email: data['email'])
  subject = 'Seus dados foram atualizados!'

  email_body = <<~EMAIL
    Olá #{data['name']}, seu registro foi atualizado na aplicação om30. Segue seus dados cadastrados atualizados:

    Nome: #{data['name']}
    Sobrenome: #{data['last_name']}
    E-mail: #{data['email']}
    CPF: #{data['cpf']}
    CNS: #{data['cns']}
    Data de Nascimento: #{data['date_of_birth']}
    Telefone: #{data['telephone']}
    Status: #{data['status']}
  EMAIL

  content = SendGrid::Content.new(type: 'text/plain', value: email_body)

  mail = SendGrid::Mail.new(from_email, subject, to_email, content)

  sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  response = sg.client.mail._('send').post(request_body: mail.to_json)
  puts response.status_code
  puts response.body
  puts response.headers
end

def send_sms_on_citizen_create(data)
  account_sid = ENV['TWILIO_ACCOUNT_SID']
  auth_token = ENV['TWILIO_AUTH_TOKEN']
  client = Twilio::REST::Client.new(account_sid, auth_token)

  message = "Olá #{data['name']}, seu registro foi criado na aplicação om30. Bem-vindo!"

  client.messages.create(
    from: 'twillo-phone',
    to: data['telephone'],
    body: message
  )
end

def send_sms_on_citizen_update(data)
  account_sid = ENV['TWILIO_ACCOUNT_SID']
  auth_token = ENV['TWILIO_AUTH_TOKEN']
  client = Twilio::REST::Client.new(account_sid, auth_token)

  message = "Olá #{data['name']}, seu registro na aplicação om30 foi atualizado."

  client.messages.create(
    from: 'twillophone',
    to: data['telephone'],
    body: message
  )
end

def start_kafka_consumer(group_id, topic, email_method)
  loop do
    kafka = Kafka.new(['localhost:9092'])
    consumer = kafka.consumer(group_id:)
    consumer.subscribe(topic)

    puts "Consumidor Kafka para #{topic} iniciado..."

    consumer.each_batch do |batch|
      batch.messages.each do |message|
        puts "Mensagem recebida do tópico #{topic}: #{message.value}"
        data = JSON.parse(message.value)
        puts "Enviando e-mail para: #{data['email']}"
        send(email_method, data)
      end

      consumer.mark_message_as_processed(batch.messages.last)
      consumer.commit_offsets
    end
  rescue Kafka::ConnectionError => e
    puts "Erro de conexão com o Kafka: #{e.message}. Tentando reconectar em 10 segundos..."
    sleep 10
  rescue StandardError => e
    puts "Erro ao processar a mensagem: #{e.message}"
  end
end

threads = []

threads << Thread.new do
  start_kafka_consumer('citizen_email_sender_on_create', 'email-citizen-create', :send_email_on_citizen_create)
end

threads << Thread.new do
  start_kafka_consumer('citizen_email_sender_on_update', 'email-citizen-update', :send_email_on_citizen_update)
end

threads << Thread.new do
  start_kafka_consumer('citizen_sms_sender_on_create', 'sms-citizen-create', :send_sms_on_citizen_create)
end
threads << Thread.new do
  start_kafka_consumer('citizen_sms_sender_on_update', 'sms-citizen-update', :send_sms_on_citizen_update)
end

threads.each(&:join)
