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
        Spinner.run(label) { yield }
      rescue StandardError => error
        output error
      end
    end
  end
end
