require_relative 'base'

module OctoKeeper
  module GithubEventHandlers
    class NotImplemented < Base
      private

      def entrypoint
        fail OctoKeeper::GithubEventHandlers::ProcessingError.new(501, "I don't know how to handle this event.")
      end
    end
  end
end
