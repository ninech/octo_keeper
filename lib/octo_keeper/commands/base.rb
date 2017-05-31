require 'octokit'
require 'tty-table'
require 'tty-spinner'
require 'pastel'

module OctoKeeper
  module Commands
    class Base < Thor
      attr_accessor :octokit_client
      attr_accessor :output_stream

      def initialize(*args)
        @output_stream = $stdout
        @octokit_client = Octokit::Client.new
        super
      end

      private

      def pastel
        @pastel ||= Pastel.new enabled: @output_stream.tty?
      end

      def output(string)
        @output_stream.puts string
      end

      def table_output(header)
        table = TTY::Table.new header: header
        yield table
        output table.render(:basic)
        output ""
        output pastel.green("The list has #{pastel.bold(table.size[0])} items.")
      end

      def with_spinner(label)
        return yield unless @output_stream.tty?
        spinner = TTY::Spinner.new("[:spinner] #{label}", format: :classic)
        spinner.run do
          yield spinner
        end
        spinner.success("(done)")
      rescue StandardError => error
        spinner.error("(error)")
        output error.message
      end
    end
  end
end
