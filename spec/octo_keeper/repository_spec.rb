require 'spec_helper'

RSpec.describe OctoKeeper::Repository do
  let(:repository) { described_class.new attributes }
  let(:attributes) do
    {
      'full_name' => 'ninech/octo-keeper',
      'name' => 'octo-keeper',
      'owner' => { 'login' => 'ninech' },
    }
  end

  describe '#initialize' do
    it 'extracts the full_name' do
      expect(repository.full_name).to eq 'ninech/octo-keeper'
    end

    it 'extracts the name' do
      expect(repository.name).to eq 'octo-keeper'
    end

    it 'extracts the owner name' do
      expect(repository.owner).to eq 'ninech'
    end
  end

  describe '#team_permissions' do
    around do |example|
      OctoKeeper.config = OctoKeeper::Configuration.new 'repositories' => {
        'default' => { 'permissions' => { 'bots' => 'push' } },
      }
      example.call
      OctoKeeper.config = nil
    end

    it 'returns the permissions key from the repository config' do
      expect(repository.team_permissions).to eq('bots' => 'push')
    end
  end
end
