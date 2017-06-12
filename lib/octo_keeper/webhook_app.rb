require 'sinatra/base'

# This command can start a webserver which is able to receive and process
# organization webhooks from Github.
# https://developer.github.com/v3/activity/events/types/#repositoryevent
module OctoKeeper
  class WebhookApp < Sinatra::Base
    before do
      # check for secret in header
    end

    error JSON::ParserError do
      status 500
      { error: 'Cannot parse payload. Invalid JSON.' }.to_json
    end

    post '/' do
      "Action #{parsed_body['action']} on #{parsed_body['repository']['full_name']}!"
    end

    private

    def parsed_body
      return @parsed_body if @parsed_body
      request.body.rewind
      @parsed_body = JSON.parse(request.body.read)
    end
  end
end
