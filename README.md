Projeto Ruby on Rails
Este projeto Ruby on Rails utiliza Docker e Docker Compose, Kafka, Zookeeper e um consumidor Kafka personalizado.

Pré-requisitos
Docker
Docker Compose
Configuração
1. Clonar o Repositório
Clone o repositório do projeto para sua máquina local.

2. Variáveis de Ambiente
Crie um arquivo .env na raiz do projeto com as seguintes variáveis de ambiente:

env
Copy code
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_REGION=your_aws_region
SENDGRID_API_KEY=your_sendgrid_api_key
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
Substitua your_aws_access_key, your_aws_secret_key, etc., pelos valores apropriados.

3. Construir e Executar com Docker Compose
Execute o comando abaixo para construir e iniciar os serviços:

bash
Copy code
docker-compose up --build
Verificação de Contêineres
Para verificar se todos os contêineres estão rodando:

bash
Copy code
docker ps
Deve listar: zookeeper, kafka e kafka_consumer.

Instanciação Individual de Contêineres
Se algum contêiner não iniciar, execute individualmente:

Zookeeper:

bash
Copy code
docker-compose up zookeeper
Kafka:

bash
Copy code
docker-compose up kafka
Inicie o Zookeeper primeiro.

Kafka Consumer:

bash
Copy code
docker-compose up kafka_consumer
Inicie o Kafka primeiro. Executa kafka_consumer.rb.

Geração de Chaves API
AWS S3
Acesse o Console AWS.
Navegue até o IAM e crie um novo usuário com acesso programático.
Anote a AWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY.
SendGrid
Crie uma conta no SendGrid.
Navegue até "API Keys" no painel.
Crie uma nova API Key e anote-a.
Twilio
Cadastre-se no Twilio.
Obtenha ACCOUNT SID e AUTH TOKEN no painel.
Testes e Qualidade do Código
Rubocop
Execute Rubocop com:

bash
Copy code, na raiz do projeto
rubocop -A
Este README fornece uma visão geral básica do projeto e instruções para configuração e execução. Para informações mais detalhadas sobre o funcionamento interno do projeto ou contribuições, considere adicionar seções adicionais conforme necessário.

aplicação rails

ao final rode:
bundle install
rails s