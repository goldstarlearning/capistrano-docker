lock "3.4.0"

set :organization, "goldstarlearning"
set :application, "capistrano-docker"
set :repo_url,    "git@github.com:goldstarlearning/capistrano-docker.git"
set :branch, fetch(ENV["BRANCH"], `git rev-parse --abbrev-ref HEAD`.rstrip)
