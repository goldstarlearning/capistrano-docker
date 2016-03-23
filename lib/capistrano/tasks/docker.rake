require "capistrano/docker/remote"

namespace :docker do
  task set_container_tags: ["deploy:set_current_revision"] do
    set :image_name, -> {
      "%s/%s:%s-%s" % [
        fetch( :organization, "ORGANIZATION-NOT-SET" ),
        fetch( :application ),
        fetch( :branch ),
        fetch( :current_revision)
      ]
    }

    set :image_tag, -> {
      [fetch( :branch ), fetch( :current_revision )].join "-"
    }

    set :container_name, -> {
      [fetch( :application ),
       fetch( :image_version )
      ].join( "-" )
    }
  end

  desc <<-DESC
  Run the application container.
  DESC
  task deploy: :install do
    container_name = fetch( :container_name )

    on roles( :app ) do |host|
      if running?( container_name )
        message host, "#{container_name} is already running"
        next
      end

      container_sub_name = [
        fetch( :application ),
        fetch( :branch )
      ].join "-"

      message host, "Removing #{container_sub_name}*"
      capture( :docker, :ps,
               %Q( | awk "/#{container_sub_name}/ { print \\$1 }" ) ).
        lines.
        each do |docker_id|
        message host, "Remove container #{docker_id}"
        execute( :docker, :rm, "-f", docker_id, "|| true" )
      end

    end
  end

  desc <<-DESC
  Install built docker image onto application servers.

  Installation is via copy from role :build to role :app.
  DESC
  task install: [:build, "docker:set_container_tags"] do
    Docker::Remote.new(
      fetch( :application ),
      org: fetch( :organization )
    ).install_image(
      image:      fetch( :docker_image ),
      tag:        fetch( :image_tag),
      image_file: fetch( :image_file )
    )
  end

  desc <<-DESC
  Build the docker image.

  The image will be built remotely on the 'primary' machine with the
  'build' role.

      server "myserver.company.com", roles: %w{build}, primary: true

  The built docker image will be tagged with the value set by:

      set :organization, "org"
      set :application,  "app"
      set :branch, fetch(ENV["BRANCH"], `git rev-parse --abbrev-ref HEAD`.rstrip)

  To create an image tagged: "org/project:env-SHA"

  Images that already exist will not be built again.
  DESC
  task build: :set_container_tags do
    on roles( :build, filter: :primary ) do |host|
      path = File.join( shared_path,
                        fetch( :image_name ).
                          gsub( /[:\/]/, "-" ) + ".tar" )
      set :image_file, path

      if test "[ -f #{fetch :image_file} ]"
        message host, "#{fetch :image_file} already built"
      else
        within release_path do
          execute :docker, :build,
                  "-t", fetch( :image_name ),
                  "."

          execute :docker, :save,
                  "-o", path,
                  fetch( :image_name )
        end
      end
    end
  end

  desc "Clean docker images older than :keep_images_for_days [3]"
  task :clean do

  end

  desc "Pull the latest docker build"
  task :pull do
    on roles( :app ) do |host|
      execute :docker, :pull, fetch( :image_name )
    end
  end

  desc <<-EOS
  List running container for deployment branch.

  Containers are searched by name matching:

      [fetch( :application ), fetch( :branch )].join "-"

  e.g., "myapp-master"
  EOS
  task :show do
    on roles( :app ) do |host|
      branch_app = [fetch( :application ), fetch( :branch )].join "-"
      message host, "Listing containers matching #{branch_app}"
      message host, capture( :docker, :ps,
                             %Q( | awk "/#{branch_app}/ { print \\$1 }" ) )
    end
  end


  desc "Show running docker containers"
  task :ps do
    on roles( :app ) do |host|
      puts capture( :docker, :ps, "-a" )
    end
  end
end

after  "deploy:updated",   "docker:build"
before "deploy:published", "docker:deploy"
after  "deploy:published", "docker:clean"
