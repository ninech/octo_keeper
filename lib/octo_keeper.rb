require "octo_keeper/version"
require "octo_keeper/cli"

require "pastel"

module OctoKeeper
  def self.pastel
    @pastel ||= Pastel.new
  end
end
