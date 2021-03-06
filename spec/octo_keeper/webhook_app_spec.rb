require 'spec_helper'
require 'json'
require 'rack/test'

RSpec.describe OctoKeeper::WebhookApp do
  include Rack::Test::Methods

  let(:app)               { described_class }
  let(:github_secret)     { 'super-secret' }
  let(:payload)           { File.read('spec/fixtures/example-repository-create-event.json') }
  let(:configuration)     { { 'repositories' => { 'default' => { 'permissions' => { 'bots' => 'pull' } } } } }
  let(:payload_signature) do
    'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), github_secret, payload)
  end

  let(:octokit_client) do
    instance_double 'Octokit::Client', add_team_repository: true, org_teams: [double(id: 1000, slug: 'bots')]
  end
  before { allow(OctoKeeper).to receive(:octokit_client).and_return(octokit_client) }

  before { allow(OctoKeeper.config).to receive(:github_secret).and_return(github_secret) }

  around do |example|
    OctoKeeper.config = OctoKeeper::Configuration.new configuration
    example.call
    OctoKeeper.config = nil
  end

  describe 'GET /ping' do
    it 'returns the timestamp' do
      get '/ping'
      expect(JSON.parse(last_response.body)).to have_key 'pong'
    end

    it 'returns status code 200' do
      get '/ping'
      expect(last_response.status).to eq 200
    end
  end

  describe 'POST /' do
    before { header 'X-Hub-Signature', payload_signature }

    it 'is successful' do
      post '/', payload
      expect(last_response.status).to eq 200
    end

    it 'sets permissions for the repository according to the settings' do
      expect(octokit_client).to receive(:add_team_repository).
        with(1000, 'ninech-test/yolo', permission: 'pull')
      post '/', payload
    end

    context 'for non-create actions' do
      let(:payload) { { "action" => "deleted", "repository" => {} }.to_json }

      it 'returns a successful code' do
        post '/', payload
        expect(last_response.status).to eq 200
      end
    end

    context 'for unknown events' do
      let(:payload) { { "action" => "yolo" }.to_json }

      it 'returns a meaningful return code' do
        post '/', payload
        expect(last_response.status).to eq 400
      end
    end

    context 'when a team does not exist' do
      before { allow(OctoKeeper::Team).to receive(:from_slug).and_return(nil) }

      it 'skips the team' do
        expect { post '/', payload }.to_not raise_exception
        expect(last_response.status).to eq 200
      end
    end

    context 'without providing a valid secret' do
      before { header 'X-Hub-Signature', nil }

      it 'returns an appropriate status code' do
        post '/', payload
        expect(last_response.status).to eq 403
      end
    end

    context 'when no github secret is configured' do
      before { allow(OctoKeeper.config).to receive(:github_secret).and_return(nil) }

      it 'returns an appropriate status code' do
        post '/', payload
        expect(last_response.status).to eq 200
      end
    end
  end
end
