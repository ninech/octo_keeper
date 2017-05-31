module OctoKeeper
  class Spinner
    def self.run(label, &block)
      new(label).run(&block)
    end

    def initialize(label)
      @spinner = TTY::Spinner.new("[:spinner] #{label}", format: :classic)
    end

    def run(&_block)
      @spinner.run do
        begin
          yield
          @spinner.success("(done)")
        rescue StandardError => error
          @spinner.error("(error)")
          raise error
        end
      end
    end
  end
end
