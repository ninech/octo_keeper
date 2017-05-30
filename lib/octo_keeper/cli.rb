require 'thor'
require 'octokit'
require 'pry'
require 'tty-table'

module OctoKeeper
  class CLI < Thor
    desc "repos", "Shows our repositories on Github"
    def repos
      table_output(%w(Name Description)) do |table|
        client.org_repos(OctoKeeper::ORGANIZATION, type: 'all').each do |repo|
          table << [repo.name, repo.description.to_s[0..50]]
        end
      end
    end

    desc "teams", "List the organization's teams."
    def teams
      table_output(%w(ID Name Description)) do |table|
        client.org_teams(OctoKeeper::ORGANIZATION).each do |team|
          table << [team.id, team.slug, team.description.to_s[0..50]]
        end
      end

    end

    private

    def client
      @client ||= Octokit::Client.new
    end

    def table_output(header)
      table = TTY::Table.new header: header
      yield table
      puts table.render(:ascii)
      puts ""
      puts OctoKeeper.pastel.green("The list has #{OctoKeeper.pastel.bold(table.size[0])} items.")
    end
  end
end
