require "octo_keeper/webhook_app"

module OctoKeeper
  module Commands
    class Webhook < Thor
      desc 'start', 'Starts the webhook in the foreground'
      option :port, type: :numeric, default: 4567, banner: 'PORT', desc: 'The on which to listen for requests.'
      option :bind, type: :string, default: 'localhost', desc: 'The interface to listen on.'
      option :config, type: :string, default: '~/.octo-keeper.yml', desc: 'Path to the config file.'
      option 'github-secret', type: :string,
                              desc: 'A secret token to share with Github.com. Default: $OCTOKEEPER_GITHUB_TOKEN.'
      def start
        load_configuration

        say "Starting version #{OctoKeeper::VERSION} of OctoKeeper Github webhook."

        port = OctoKeeper.config.port || options[:port]
        bind = OctoKeeper.config.bind || options[:bind]
        OctoKeeper.config.github_secret ||= options['github-secret']

        OctoKeeper::WebhookApp.run! port: port, bind: bind
      end

      private

      def load_configuration
        OctoKeeper::Configuration.load options[:config]
      rescue OctoKeeper::ConfigNotFoundError => error
        say error.message
        say "Using default configuration."
      end
    end
  end
end
