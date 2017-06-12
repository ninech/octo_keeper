require "octo_keeper/webhook_app"

module OctoKeeper
  module Commands
    class Webhook < Thor
      desc 'start', 'Starts the webhook in the foreground'
      option :port, type: :numeric, default: 4567, banner: 'PORT', desc: 'The on which to listen for requests.'
      option :bind, type: :string, default: 'localhost', desc: 'The interface to listen on.'
      def start
        OctoKeeper::WebhookApp.run! port: options[:port], bind: options[:bind]
      end
    end
  end
end
