module OctoKeeper
  module GithubEventHandlers
    class Ping < Base
      private

      def entrypoint
        "OK"
      end
    end
  end
end
