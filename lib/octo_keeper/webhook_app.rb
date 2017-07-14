require 'sinatra/base'

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

    get '/ping' do
      { pong: DateTime.now.rfc3339 }.to_json
    end

    post '/' do
      verify_signature!(payload_body)
      return halt 400, { message: 'OctoKeeper cannot handle this event.' }.to_json unless parsed_body['repository']

      repository = Repository.new parsed_body['repository']
      logger.info %(Received "#{parsed_body['action']}" event for repository #{repository.full_name}.)

      handle_repository_created(repository) if parsed_body['action'] == 'created'

      { status: "OK" }.to_json
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

    def handle_repository_created(repository)
      repository.team_permissions.each_pair do |team_slug, permission|
        team = Team.from_slug(repository.owner, team_slug, client: OctoKeeper.octokit_client)
        save_permissions(team, repository, permission)
      end
    end

    def save_permissions(team, repository, permission)
      OctoKeeper.octokit_client.add_team_repository(team.id, repository.full_name, permission: permission)
      logger.info "Added #{permission} permission for team #{team.slug} on #{repository.name}."
    rescue StandardError => e
      logger.error "Setting permissions for team #{team_slug} failed: #{e.message}"
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
