# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "octo_keeper/version"

Gem::Specification.new do |spec|
  spec.name          = "octo_keeper"
  spec.version       = OctoKeeper::VERSION
  spec.authors       = ["Philippe Hässig"]
  spec.email         = ["phil@nine.ch"]

  spec.summary       = "Maintains our Github repos"
  spec.description   = "Octo-Keeper is responsible to keep the settings of our Github repos in sync."
  spec.homepage      = "https://github.com/ninech/octo_keeper"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.nine.ch/private"
  else
    fail "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "octokit"
  spec.add_dependency "tty-table"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
end
