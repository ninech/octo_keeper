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
    end
  end
end
