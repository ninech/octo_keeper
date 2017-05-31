require 'octokit'
require 'tty-table'
require 'tty-spinner'
require 'pastel'

module OctoKeeper
  module Commands
    class Base < Thor
      private

      def octokit_client
        @octokit_client ||= Octokit::Client.new
      end

      def pastel
        @pastel ||= Pastel.new
      end

      def table_output(header)
        table = TTY::Table.new header: header
        yield table
        puts table.render(:basic)
        puts ""
        puts pastel.green("The list has #{pastel.bold(table.size[0])} items.")
      end

      def with_spinner(label)
        spinner = TTY::Spinner.new("[:spinner] #{label}", format: :classic)
        spinner.run do
          begin
            yield spinner
            spinner.success("(done)")
          rescue StandardError => error
            spinner.error("(error)")
            puts error.message
          end
        end
      end
    end
  end
end
