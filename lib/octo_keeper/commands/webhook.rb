require "octo_keeper/webhook_app"

module OctoKeeper
  module Commands
    class Webhook < Thor
      desc 'start', 'Starts the webhook in the foreground'
      option :port, type: :numeric, default: 4567, banner: 'PORT', desc: 'The on which to listen for requests.'
      option :bind, type: :string, default: 'localhost', desc: 'The interface to listen on.'
      def start
        load_configuration

        port = OctoKeeper.config.port || options[:port]
        bind = OctoKeeper.config.bind || options[:bind]
        OctoKeeper::WebhookApp.run! port: port, bind: bind
      end

      private

      def load_configuration
        OctoKeeper::Configuration.load 'config.yml'
      rescue OctoKeeper::ConfigNotFoundError => error
        say error.message
        say "Using default configuration."
      end
    end
  end
end
