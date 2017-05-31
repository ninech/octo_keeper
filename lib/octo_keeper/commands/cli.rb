module OctoKeeper
  module Commands
    class CLI < Base
      class_option :org, type: :string, required: true, banner: "Github organization"

      desc "repos SUBCOMMAND", "Manage your organization's repositories."
      subcommand :repos, Repos

      desc "teams SUBCOMMAND", "Manage your organization's teams."
      subcommand :teams, Teams

      desc "apply-team TEAM PERMISSION", "Applies the PERMISSION on all repos to the TEAM. PERMISSION must be admin, push or pull."
      def apply_team(team_id, permission)
        unless %w(admin push pull).include?(permission)
          output pastel.red("Permission must be one of admin, push, pull.")
          exit 1
        end

        if team_id.to_i <= 0 && team_id != 'all'
          output pastel.red("Team ID must be 'all' or a team id. Run 'octo-keeper teams' to get the number.")
          exit 1
        end

        teams = if team_id == 'all'
                  octokit_client.org_teams(options[:org])
                else
                  [octokit_client.team(team_id)]
                end

        teams.each do |team|
          output "🔑  Applying permissions for team #{team.name}"
          apply_repo_permissions_for_team(team, permission)
        end
      end

      private

      def apply_repo_permissions_for_team(team, permission)
        octokit_client.org_repos(options[:org]).each do |repo|
          with_spinner(repo.full_name) do
            octokit_client.add_team_repository(team.id, repo.full_name, permission: permission)
          end
        end
      end
    end
  end
end
