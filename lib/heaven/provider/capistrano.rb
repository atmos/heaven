module Heaven
  # Top-level module for providers.
  module Provider
    # The capistrano provider.
    class Capistrano < DefaultProvider
      def initialize(guid, payload)
        super
        @name = "capistrano"
      end

      def cap_path
        gem_executable_path("cap")
      end

      def task
        name = data["task"] || "deploy"
        unless name =~ /deploy(?:\:[\w+:]+)?/
          fail "Invalid capistrano taskname: #{name.inspect}"
        end
        name
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
          deploy_string = [cap_path, environment, "-s", "branch=#{ref}", task]
          log "Executing capistrano: #{deploy_string.join(" ")}"
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
