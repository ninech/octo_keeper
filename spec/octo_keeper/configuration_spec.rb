require 'spec_helper'

RSpec.describe OctoKeeper::Configuration do
  describe '.load' do
    before { allow(YAML).to receive(:load_file).and_return({}) }
    after  { OctoKeeper.config = nil }

    it 'reads the config from a file' do
      expect(YAML).to receive(:load_file).with(File.expand_path('config.yml')).and_return({})
      described_class.load
    end

    it 'assigns the config to the module' do
      described_class.load
      expect(OctoKeeper.config).to be_a OctoKeeper::Configuration
    end

    context 'when the file was not found' do
      it 'raises an error' do
        allow(YAML).to receive(:load_file).and_raise(Errno::ENOENT, 'File not found.')
        expect { described_class.load }.to raise_exception OctoKeeper::ConfigNotFoundError
      end
    end
  end

  describe '#initialize' do
    it 'assigns the port' do
      expect(described_class.new('port' => 80).port).to eq 80
    end

    it 'assigns the bind' do
      expect(described_class.new('bind' => '0.0.0.0').bind).to eq '0.0.0.0'
    end

    it 'assigns the repositories' do
      expect(described_class.new('repositories' => [1]).repositories).to eq [1]
    end
  end

  describe '#repository_config' do
    let(:config) { described_class.new(YAML.safe_load(config_yaml)) }
    let(:config_yaml) do
      <<-YAML
      repositories:
        default:
          permissions:
            bots: pull
        ninech/octokeeper:
          permissions:
            bots: admin
        ninech/webhook:
          permissions:
            deployment: pull
      YAML
    end

    it 'returns the default config for unconfigured repositoryes' do
      expect(config.repository_config('ninech/yolo')).to eq('permissions' => { 'bots' => 'pull' })
    end

    it 'allows to overwrite default settings' do
      expect(config.repository_config('ninech/octokeeper')).to eq('permissions' => { 'bots' => 'admin' })
    end

    it 'allows to add additional permissions' do
      expect(config.repository_config('ninech/webhook')).to eq(
        'permissions' => { 'bots' => 'pull', 'deployment' => 'pull' }
      )
    end
  end
end
