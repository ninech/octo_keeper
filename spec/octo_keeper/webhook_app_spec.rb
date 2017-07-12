require 'spec_helper'
require 'json'
require 'rack/test'

RSpec.describe OctoKeeper::WebhookApp do
  include Rack::Test::Methods

  let(:app) { described_class }
  let(:payload) { File.read('spec/fixtures/example-repository-create-event.json') }
  let(:configuration) { { 'repositories' => { 'default' => { 'permissions' => { 'bots' => 'pull' } } } } }

  let(:octokit_client) do
    instance_double 'Octokit::Client', add_team_repository: true, org_teams: [double(id: 1000, slug: 'bots')]
  end
  before { allow(OctoKeeper).to receive(:octokit_client).and_return(octokit_client) }

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
    it 'is successful' do
      post '/', payload
      expect(last_response.status).to eq 200
    end

    it 'sets permissions for the repository according to the settings' do
      expect(octokit_client).to receive(:add_team_repository).
        with(1000, 'ninech-test/yolo', permission: 'pull')
      post '/', payload
    end
  end
end
