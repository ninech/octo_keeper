require 'spec_helper'

RSpec.describe OctoKeeper::Commands::Repos do
  let(:repo) { double(name: 'Yolo', description: 'Yolo Desc') }
  let(:command) { described_class.new [], org: 'yolo' }
  let(:console_output) { command.output_stream.string }

  before do
    command.octokit_client = instance_double('Octokit::Client', org_repos: [repo])
    command.output_stream = StringIO.new
  end

  describe "#list" do
    before { command.list }

    it 'draws a table header' do
      expect(console_output).to match(/^Name Description$/)
    end

    it 'shows the repo name' do
      expect(console_output).to match(/^Yolo/)
    end

    it 'shows the repo description' do
      expect(console_output).to include "Yolo Desc"
    end

    it 'shows how many repos there are' do
      expect(console_output).to include "The list has 1 items."
    end
  end
end
