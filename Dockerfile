#FROM ruby:2.1-slim
FROM ruby:2.7-slim

ENV STOPLIGHT_SERVER_URL ''
ENV STOPLIGHT_USERNAME ''
ENV STOPLIGHT_PASSWORD ''

EXPOSE 5000
WORKDIR /opt/app

RUN mkdir -p /opt/app

COPY Gemfile /opt/app/
COPY Gemfile.lock /opt/app/
RUN bundle config set without 'development test'
RUN bundle install
COPY . /opt/app

# Fix permissions for OpenShift (remove if you don't run the container there)
RUN chgrp -R 0 /opt/app && chmod -R g+rwX /opt/app

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5000"]
