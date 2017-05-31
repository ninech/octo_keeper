require 'thor'
require 'octokit'
require 'tty-table'
require 'tty-spinner'

require "octo_keeper/version"
require "octo_keeper/cli"

require "pastel"

module OctoKeeper
  def self.pastel
    @pastel ||= Pastel.new
  end
end
