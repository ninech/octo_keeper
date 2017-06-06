require 'spec_helper'

RSpec.describe OctoKeeper::Commands::Teams do
  let(:team) { double(id: 12345, slug: 'admins', description: 'The administrators guild', name: 'Admins') }
  let(:repository) { double(full_name: 'ninech/octo_keeper') }
  let(:command) { described_class.new }
  let(:console_output) { command.output_stream.string }
  let(:octokit_client) { instance_double('Octokit::Client', org_teams: [team], team: team, org_repos: [repository]) }

  before do
    command.octokit_client = octokit_client
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

  describe '#show' do
    before { command.show(slug) }

    context 'for an existing team' do
      let(:slug) { 'admins' }

      it 'shows the team name' do
        expect(console_output).to include 'Admins'
      end

      it 'shows the team ID' do
        expect(console_output).to include '12345'
      end

      it 'shows the team description' do
        expect(console_output).to include 'The administrators guild'
      end
    end

    context 'for an not existing team' do
      let(:slug) { 'bots' }

      it 'shows a message' do
        expect(console_output.chomp).to eq 'No team with this name was found.'
      end
    end
  end

  describe '#apply' do
    let(:permission) { 'admin' }

    it 'gives permissions to the team' do
      expect(command.octokit_client).to receive(:add_team_repository).
        with(12345, "ninech/octo_keeper", permission: "admin")
      command.apply(12345, permission)
    end

    it 'fails when the team was not found' do
      expect(octokit_client).to receive(:team).and_raise(Octokit::NotFound)
      command.apply(1, permission)
      expect(console_output).to include 'No team with ID 1 found'
    end

    it 'rejects invalid team ids' do
      expect { command.apply('hello', permission) }.to raise_error SystemExit
      expect(console_output).to include 'Team ID must be a number'
    end

    it 'rejects invalid permissions' do
      expect { command.apply(1, 'yolo') }.to raise_error SystemExit
      expect(console_output).to include 'Permission must be one of admin, push, pull'
    end
  end
end
