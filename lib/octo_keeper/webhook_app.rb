require 'sinatra/base'
require_relative 'github_event_handlers'

# This command can start a webserver which is able to receive and process
# organization webhooks from Github.
# https://developer.github.com/v3/activity/events/types/#repositoryevent
module OctoKeeper
  class WebhookApp < Sinatra::Base
    configure :production, :development do
      enable :logging
    end

    error JSON::ParserError do
      logger.error "Received unparsable JSON payload."
      status 500
      { error: 'Cannot parse payload. Invalid JSON.' }.to_json
    end

    before %r{\/((?!ping).)*} do # all except /ping
      verify_signature!(payload_body)
    end

    get '/ping' do
      { pong: DateTime.now.rfc3339 }.to_json
    end

    post '/' do
      handler.process do |status, message|
        halt status, { message: message }.to_json
      end
    end

    private

    def payload_body
      return @payload_body if @payload_body
      request.body.rewind
      @payload_body = request.body.read
    end

    def parsed_body
      @parsed_body ||= JSON.parse(payload_body)
    end

    def event
      request.env['HTTP_X_GITHUB_EVENT'].to_s
    end

    def handler
      @handler ||= OctoKeeper::GithubEventHandlers.from_event_name(event, parsed_body, logger)
    end

    def verify_signature!(payload_body)
      secret = OctoKeeper.config.github_secret
      return true unless secret

      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload_body)
      return if Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'].to_s)
      halt 403, { message: "Invalid access token!" }.to_json
    end
  end
end
