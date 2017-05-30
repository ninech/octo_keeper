require 'thor'
require 'octokit'
require 'pry'
require 'tty-table'
require 'tty-spinner'

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

    desc "apply TEAM PERMISSION", "Applies the PERMISSION on all repos to the TEAM. PERMISSION must be admin, push or pull."
    def apply(team_id, permission)
      unless %w(admin push pull).include?(permission)
        puts OctoKeeper.pastel.red("Permission must be one of admin, push, pull.")
        exit 1
      end

      team = client.team(2368730)
      puts OctoKeeper.pastel.underline.bold("🔑  Applying permissions for team #{team.name}")

      client.org_repos(OctoKeeper::ORGANIZATION).each do |repo|
        spinner = TTY::Spinner.new "[:spinner] #{repo.full_name}", format: :arc
        spinner.run do
          begin
            client.add_team_repository(team.id, repo.full_name, permission: permission)
            spinner.success("(done)")
          rescue Octokit::UnprocessableEntity => error
            spinner.error("(error)")
            puts error.message
          end
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
      puts table.render(:basic)
      puts ""
      puts OctoKeeper.pastel.green("The list has #{OctoKeeper.pastel.bold(table.size[0])} items.")
    end
  end
end
