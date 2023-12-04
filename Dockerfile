FROM ruby:3.2.2
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
CMD ["ruby", "kafka_consumer.rb"]
