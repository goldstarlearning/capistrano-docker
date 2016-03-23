module Capistrano
  module Docker
    class Remote
      attr_reader :org, :application

      def initialize( application, org: "goldstarlearning" )
        @org = org
        @application = application
      end

      def self.loaded?( image: fetch( :docker_image ), tag: "latest" )
        "docker images | grep '#{image} *#{Regexp.escape tag} '"
      end

      def self.running?( name )
        "docker ps | grep #{Regexp.escape name}"
      end

      # For the moment
      # rubocop:disable all
      def install_image( image:, tag:, image_file: )
        file_server = roles( :build, filter: :primary ).first

        on roles( :app ) do |host|
          if test "docker images | grep '#{image} *#{Regexp.escape tag} '"
            message host, "#{tag} already installed"
            next
          end

          unless test( "[ -f #{image_file} ]" )
            message host,
                    "Copying #{tag} " \
                    "from #{file_server.hostname}"

            execute :scp,
                    "%s@%s:%s" % [file_server.user,
                                  file_server.hostname,
                                  image_file],
                    shared_path
          end

          tar_file = shared_path.join File.basename( image_file )
          execute :docker, :load, "-i", tar_file
          execute :rm, tar_file
        end
      end
    end
  end
end

