require "capistrano/docker/version"
load File.expand_path( "../tasks/docker.rake", __FILE__ )

module Capistrano
  module Docker
  end
end
