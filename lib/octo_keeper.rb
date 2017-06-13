require "thor"

require "octo_keeper/version"
require "octo_keeper/configuration"
require "octo_keeper/spinner"
require "octo_keeper/repository"
require "octo_keeper/team"

require "octo_keeper/commands/base"
require "octo_keeper/commands/teams"
require "octo_keeper/commands/repos"
require "octo_keeper/commands/webhook"
require "octo_keeper/commands/cli"

module OctoKeeper
  def self.octokit_client
    @octokit_client ||= Octokit::Client.new
  end
end
