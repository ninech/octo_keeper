module OctoKeeper
  module Commands
    class Teams < Base
      desc "list", "Shows all the teams of your organization."
      def list
        table_output(%w(ID Name Description)) do |table|
          octokit_client.org_teams(options[:org]).each do |team|
            table << [team.id, team.slug, team.description.to_s[0..50]]
          end
        end
      end

      desc "apply TEAM PERMISSION", %(Applies the PERMISSION on all repos for the TEAM.)
      long_desc <<-LONG_DESC
        PERMISSION must be admin, push or pull.
        TEAM must be the team's numerical ID.

        To apply a permission for a team run:

        > $ octo-keeper teams --org ninech apply 12345 admin
      LONG_DESC
      def apply(team_id, permission)
        verify_team_id! team_id
        verify_permission_string! permission

        team = octokit_client.team(team_id)
        output "🔑  Applying permissions for team #{team.slug}"
        apply_repo_permissions_for_team(team, permission)
      rescue Octokit::NotFound
        output pastel.red("No team with ID #{team_id} found.")
      end

      private

      def verify_permission_string!(permission)
        return true if %w(admin push pull).include?(permission)
        output pastel.red("Permission must be one of admin, push, pull.")
        exit 1
      end

      def verify_team_id!(team_id)
        return true if team_id.to_i > 0
        output pastel.red("Team ID must be a number. Run 'octo-keeper teams' to get the ID.")
        exit 1
      end

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
