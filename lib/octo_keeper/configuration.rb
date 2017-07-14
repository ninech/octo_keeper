require 'yaml'

module OctoKeeper
  class ConfigNotFoundError < StandardError; end

  class Configuration
    attr_reader :port, :bind
    attr_reader :repositories
    attr_writer :github_secret

    def self.load(path = 'config.yml')
      expanded_path = File.expand_path(path)
      configuration_from_file = YAML.load_file(expanded_path) || {}
      OctoKeeper.config = Configuration.new configuration_from_file
    rescue Errno::ENOENT
      raise ConfigNotFoundError, "File #{expanded_path} not found."
    end

    def initialize(config = {})
      @repositories = config['repositories'] || {}
      @port = config['port']
      @bind = config['bind']
    end

    def repository_config(name)
      deep_merge default_repository_config, @repositories[name] || {}
    end

    def default_repository_config
      @repositories['default'] || {}
    end

    def github_secret
      @github_secret || ENV['OCTOKEEPER_GITHUB_SECRET']
    end

    private

    def deep_merge(left, right)
      result = left.dup
      right.each_pair do |current_key, other_value|
        this_value = result[current_key]
        result[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
                                deep_merge(this_value, other_value)
                              else
                                other_value
                              end
      end
      result
    end
  end

  def self.config=(config)
    @config = config
  end

  def self.config
    @config ||= Configuration.new
  end
end
