require 'spec_helper'

RSpec.describe OctoKeeper::Commands::Teams do
  let(:team) { double(id: 12345, slug: 'admins', description: 'The administrators guild') }
  let(:command) { described_class.new }
  let(:console_output) { command.output_stream.string }

  before do
    command.octokit_client = instance_double('Octokit::Client', org_teams: [team])
    command.output_stream = StringIO.new
  end

  describe "#list" do
    before { command.list }

    it 'draws a table header' do
      expect(console_output).to include "ID    Name   Description"
    end

    it 'shows the team name' do
      expect(console_output).to include "admins"
    end

    it 'shows the team ID' do
      expect(console_output).to include "12345"
    end

    it 'shows the team description' do
      expect(console_output).to include "The administrators guild"
    end

    it 'shows how many teams there are' do
      expect(console_output).to include "The list has 1 items."
    end
  end
end
