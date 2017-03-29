FROM ruby:2.4-alpine
EXPOSE 9292

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app
ADD Gemfile.lock /app
RUN bundle install

ADD . /app
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0"]
