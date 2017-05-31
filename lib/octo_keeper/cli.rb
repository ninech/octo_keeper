module OctoKeeper
  class CLI < Thor
    class_option :org, type: :string, required: true, banner: "Github organization"

    desc "repos", "Shows our repositories on Github"
    def repos
      table_output(%w(Name Description)) do |table|
        client.org_repos(options[:org], type: 'all').each do |repo|
          table << [repo.name, repo.description.to_s[0..50]]
        end
      end
    end

    desc "teams", "List the organization's teams."
    def teams
      table_output(%w(ID Name Description)) do |table|
        client.org_teams(options[:org]).each do |team|
          table << [team.id, team.slug, team.description.to_s[0..50]]
        end
      end
    end

    desc "apply-team TEAM PERMISSION", "Applies the PERMISSION on all repos to the TEAM. PERMISSION must be admin, push or pull."
    def apply_team(team_id, permission)
      unless %w(admin push pull).include?(permission)
        puts OctoKeeper.pastel.red("Permission must be one of admin, push, pull.")
        exit 1
      end

      if team_id.to_i <= 0 && team_id != 'all'
        puts OctoKeeper.pastel.red("Team ID must be 'all' or a team id. Run 'octo-keeper teams' to get the number.")
        exit 1
      end

      teams = if team_id == 'all'
                client.org_teams(options[:org])
              else
                [client.team(team_id)]
              end

      teams.each do |team|
        puts "🔑  Applying permissions for team #{team.name}"
        apply_repo_permissions_for_team(team, permission)
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

    def apply_repo_permissions_for_team(team, permission)
      client.org_repos(options[:org]).each do |repo|
        with_spinner(repo.full_name) do
          client.add_team_repository(team.id, repo.full_name, permission: permission)
        end
      end
    end
  end
end
