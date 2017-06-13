module OctoKeeper
  module Commands
    class Repos < Base
      class_option :org, type: :string, required: true, banner: "Github organization"

      desc "list", "Shows all the repos of your organization."
      def list
        table_output(%w(Name Description)) do |table|
          octokit_client.org_repos(options[:org], type: 'all').each do |repo|
            table << [repo.name, repo.description.to_s[0..50]]
          end
        end
      end
    end
  end
end
