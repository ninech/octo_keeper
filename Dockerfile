FROM ruby:2.4-alpine

RUN mkdir -p /home/octo-keeper
WORKDIR /home/octo-keeper

COPY . /home/octo-keeper/

ENV RACK_ENV=production

RUN apk update && apk add git build-base && \
    gem build octo_keeper.gemspec && \
    gem install octo_keeper-*.gem && \
    apk del build-base

VOLUME /home/octo-keeper/config.yml
EXPOSE 4567

CMD ["octo-keeper", "webhook", "start", "--config", "config.yml", "--bind", "0.0.0.0"]
