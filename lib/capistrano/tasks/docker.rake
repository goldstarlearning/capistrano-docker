namespace :docker do
  desc <<-DESC
  DESC
  task :deploy do

  end

  desc <<-DESC
  Build the docker image.

  The image will be built remotely on the 'primary' machine with the
  'build' role.

    server "myserver.company.com", roles: %w{build}, primary: true

  The build docker image will be tagged with the value set by:

    set :application_container, "company/project:master-SHA"

  DESC
  task :build do
    next
    on roles( :build, filter: :primary ) do |host|
      path = File.join( shared_path,
                        fetch( :application_container ).
                          gsub( /[:\/]/, "-" ) + ".tar" )
      set :image_file, path

      if test "[ -f #{fetch :image_file} ]"
        message host, "#{fetch :image_file} already built"
      else
        within release_path do
          execute :docker, :build,
                  "-t", fetch( :application_container ),
                  "."

          execute :docker, :save,
                  "-o", path,
                  fetch( :application_container )
        end
      end
    end
  end

  desc "Clean docker images older than :keep_images_for_days [3]"
  task :clean do

  end

  desc "Show running docker containers"
  task :ps do
    on roles( :app ) do |host|
      puts capture( :docker, :ps, "-a" )
      # as :deploy do
      # end
    end
  end
end

after  "deploy:updated",   "docker:build"
before "deploy:published", "docker:deploy"
after  "deploy:published", "docker:clean"
