module Heaven
  # Top-level module for providers.
  module Provider
    # The dpl provider.
    class Dpl < DefaultProvider
      def initialize(guid, payload)
        super
        @name = "dpl"
      end

      def app_name
        return nil unless custom_payload_config
        if environment == "staging"
          custom_payload_config["heroku_staging_name"]
        else
          custom_payload_config["heroku_name"]
        end
      end

      def heroku_username
        ENV["HEROKU_USERNAME"]
      end

      def heroku_password
        ENV["HEROKU_PASSWORD"]
      end

      def heroku_api_key
        ENV["HEROKU_API_KEY"]
      end

      def dpl_path
        gem_executable_path("dpl")
      end

      def execute
        return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

        unless File.exist?(checkout_directory)
          log "Cloning #{repository_url} into #{checkout_directory}"
          execute_and_log(["git", "clone", clone_url, checkout_directory])
        end

        Dir.chdir(checkout_directory) do
          log "Fetching the latest code"
          execute_and_log(%w{git fetch})
          execute_and_log(["git", "reset", "--hard", sha])
          log "Pushing to heroku"
          deploy_string = ["#{dpl_path}",
                           "--provider=heroku",
                           "--strategy=git",
                           "--api-key=#{heroku_api_key}",
                           "--username=#{heroku_username}",
                           "--password=#{heroku_password}",
                           "--app=#{app_name}"]
          execute_and_log(deploy_string)
        end
      end

      def notify
        output.stderr = File.read(stderr_file)
        output.stdout = File.read(stdout_file)
        output.update
        if last_child.success?
          status.success!
        else
          status.failure!
        end
      end
    end
  end
end
