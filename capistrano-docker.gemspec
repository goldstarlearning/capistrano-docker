# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "capistrano/docker/version"

Gem::Specification.new do |spec|
  spec.name        = "capistrano-docker"
  spec.version     = Capistrano::Docker::Deploy::VERSION
  spec.authors     = ["Toby Tripp"]
  spec.email       = ["ttripp+github@goldstarlearning.com"]

  spec.summary     = %q{Use capistrano to deploy a docker container}
  spec.homepage    =
    "https://github.com/goldstarlearning/capistrano-docker"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/|bin/pre-docker-build})
  }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", "~> 3.1"
  spec.add_dependency "sshkit", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
