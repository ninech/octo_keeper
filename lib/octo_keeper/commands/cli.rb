module OctoKeeper
  module Commands
    class CLI < Base
      class_option :org, type: :string, required: true, banner: "Github organization"

      desc "repos SUBCOMMAND", "Manage your organization's repositories."
      subcommand :repos, Repos

      desc "teams SUBCOMMAND", "Manage your organization's teams."
      subcommand :teams, Teams

      desc "webhook SUBCOMMAND", "Run a web application which servers as a Github webhook."
      subcommand :webhook, Webhook
    end
  end
end
