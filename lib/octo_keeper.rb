require "octo_keeper/version"
require "octo_keeper/cli"

require "pastel"

module OctoKeeper
  ORGANIZATION = 'ninech'.freeze

  def self.pastel
    @pastel ||= Pastel.new
  end
end
