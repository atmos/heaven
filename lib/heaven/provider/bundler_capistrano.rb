require "heaven/provider/capistrano"

module Heaven
  # Top-level module for providers.
  module Provider
    # A capistrano provider that installs gems.
    class BundlerCapistrano < Capistrano
      def initialize(guid, payload)
        super
        @name = "bundler_capistrano"
      end

      def archive_name
        "#{name}-#{sha}.tar.gz"
      end

      def archive_link
        @archive_link ||= api.archive_link(name_with_owner, :ref => sha)
      end

      def archive_path
        @archive_path ||= "#{working_directory}/#{archive_name}"
      end

      def unpacked_directory
        @unpacked_directory ||= archive_path.chomp('.tar.gz')
      end

      def execute
        return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

        unless File.exist?(archive_path)
          log "Downloading #{archive_link} into #{archive_path}"
          execute_and_log(["curl", "-L", archive_link, ">", archive_path])
        end

        unless Dir.exist?(unpacked_directory)
          log "Unpacking tarball"
          execute_and_log(["tar", "xzf", archive_path])
        end

        Dir.chdir(unpacked_directory) do
          Bundler.with_clean_env do
            bundler_string = ["bundle", "install", "--without", ignored_groups.join(" ")]
            log "Executing bundler: #{bundler_string.join(" ")}"
            execute_and_log(bundler_string)
            deploy_string = ["bundle", "exec", "cap", environment, "-s", "branch=#{ref}", task]
            log "Executing capistrano: #{deploy_string.join(" ")}"
            execute_and_log(deploy_string, "BRANCH" => ref)
          end
        end
      end

      private

      def ignored_groups
        bundle_definition.groups - [:heaven, :deployment]
      end

      def bundle_definition
        gemfile_path = File.expand_path("Gemfile", unpacked_directory)
        lockfile_path = File.expand_path("Gemfile.lock", unpacked_directory)
        Bundler::Definition.build(gemfile_path, lockfile_path, nil)
      end
    end
  end
end
