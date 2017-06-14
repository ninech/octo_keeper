module OctoKeeper
  module Commands
    class CLI < Base
      desc "repos SUBCOMMAND", "Manage your organization's repositories."
      subcommand :repos, Repos

      desc "teams SUBCOMMAND", "Manage your organization's teams."
      subcommand :teams, Teams

      desc "webhook SUBCOMMAND", "Run a web application which servers as a Github webhook."
      subcommand :webhook, Webhook

      desc "version", "Show the version of octo-keeper."
      def version
        say OctoKeeper::VERSION
      end
    end
  end
end
