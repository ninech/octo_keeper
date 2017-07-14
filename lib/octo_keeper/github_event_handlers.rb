module OctoKeeper
  module GithubEventHandlers
    def self.from_event_name(event, parsed_body, logger)
      handler_class_name = "OctoKeeper::GithubEventHandlers::#{event.capitalize}"

      if Object.const_defined?(handler_class_name)
        handler_class = Object.const_get handler_class_name
        handler_class.new parsed_body, logger
      else
        NotImplemented.new parsed_body, logger
      end
    end
  end
end

Dir[File.dirname(__FILE__) + '/github_event_handlers/*.rb'].each { |file| require file }
