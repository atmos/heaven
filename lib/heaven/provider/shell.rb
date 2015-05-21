module Heaven
  # Top-level module for providers.
  module Provider
    # The shell provider.
    class Shell < DefaultProvider
      def initialize(guid, payload)
        super
        @name = "shell"
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
          Bundler.with_clean_env do
            log "Executing script: #{deployment_command}"
            execute_and_log([deployment_command], deployment_environment)
          end
        end
      end

      private

      def deployment_command
        script = custom_payload_config.try(:[], "deploy_script")
        fail "No deploy script configured." unless script
        fail "Only deploy scripts from the repo are allowed." unless script =~ /\A([\w-]+\/)*[\w-]+(\.\w+)?\Z/
        fail "Deploy script #{script} not found or not executable" unless File.executable?("./" + script)
        "./" + script
      end

      def deployment_environment
        {
          "BRANCH" => ref,
          "SHA" => sha,
          "DEPLOY_ENV" => environment,
          "DEPLOY_TASK" => task
        }
      end

      def task
        name = deployment_data["task"] || "deploy"
        unless name =~ /deploy(?:\:[\w+:]+)?/
          fail "Invalid taskname: #{name.inspect}"
        end
        name
      end
    end
  end
end
