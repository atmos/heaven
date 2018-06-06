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
        "#{name_without_owner}-#{sha}.tar.gz"
      end

      def archive_link
        @archive_link ||= api.archive_link(name_with_owner, :ref => sha)
      end

      def archive_path
        @archive_path ||= "#{working_directory}/#{archive_name}"
      end

      def unpacked_directory
        @unpacked_directory ||= "#{working_directory}/#{name_with_owner.gsub("/", "-")}-#{full_sha}"
      end

      def execute
        return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

        unless File.exist?(archive_path)
          log "Downloading #{archive_link} into #{archive_path}"
          execute_and_log(["curl", "-sL", archive_link, "-o", archive_path])
        end

        unless Dir.exist?(unpacked_directory)
          log "Unpacking tarball"
          execute_and_log(["tar", "-C", working_directory, "-xzf", archive_path])
        end

        Dir.chdir(unpacked_directory) do
          Bundler.with_clean_env do
            if bundler_private_source.present? && bundler_private_credentials.present?
              bundler_config_string = ["bundle", "config", bundler_private_source, bundler_private_credentials]
              log "Adding bundler config"
              execute_and_log(bundler_config_string)
            end

            bundler_string = ["bundle", "install", "--without", ignored_groups.join(" ")]
            log "Executing bundler: #{bundler_string.join(" ")}"
            execute_and_log(bundler_string)
            deploy_string = ["bundle", "exec", "cap", environment, task]
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

      def bundler_private_source
        ENV["BUNDLER_PRIVATE_SOURCE"]
      end

      def bundler_private_credentials
        ENV["BUNDLER_PRIVATE_CREDENTIALS"]
      end
    end
  end
end
