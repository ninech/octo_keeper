module OctoKeeper
  module GithubEventHandlers
    class ProcessingError < StandardError
      attr_reader :status, :message

      def initialize(status, message)
        @status = status
        @message = message
      end
    end

    class Base
      attr_reader :logger, :payload

      def initialize(payload, logger)
        @logger = logger
        @payload = payload
      end

      def process
        yield 200, entrypoint
      rescue ProcessingError => e
        logger.error e.message
        yield e.status, e.message
      end

      private

      def entrypoint
        fail ::NotImplemented
      end
    end
  end
end
