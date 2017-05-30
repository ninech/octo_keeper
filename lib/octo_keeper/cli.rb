require 'thor'
require 'octokit'
require 'pry'
require 'tty-table'

module OctoKeeper
  class CLI < Thor
    desc "repos", "Shows our repositories on Github"
    def repos
      table = TTY::Table.new header: %w(Name Description)

      client.org_repos(OctoKeeper::ORGANIZATION, type: 'all').each do |repo|
        table << [repo.name, repo.description.to_s[0..50]]
      end

      puts table.render(:ascii)
      puts ""
      puts OctoKeeper.pastel.green("Currently we have #{OctoKeeper.pastel.bold(table.size[0])} repositories.")
    end

    private

    def client
      @client ||= Octokit::Client.new
    end
  end
end
