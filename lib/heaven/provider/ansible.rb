module Heaven
  # Top-level module for providers.
  module Provider
    # The capistrano provider.
    class Ansible < DefaultProvider
      def initialize(guid, payload)
        super
        @name = "ansible"
      end

      def ansible_root
        "#{checkout_directory}/ansible"
      end

      def execute
        log "Deployment DATA from lazywei: #{deployment_data.inspect}"
        return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

        unless File.exist?(checkout_directory)
          log "Cloning #{repository_url} into #{checkout_directory}"
          execute_and_log(["git", "clone", clone_url, checkout_directory])
        end

        Dir.chdir(checkout_directory) do
          log "Fetching the latest code"
          execute_and_log(%w{git fetch})
          execute_and_log(["git", "reset", "--hard", sha])
          # deploy_string = [cap_path, environment, "-s", "branch=#{ref}", task]
          deploy_string = ["ansible-playbook", "-i", "#{ansible_root}/hosts",
                           "#{ansible_root}/site.yml", "--verbose",
                           "--extra-vars", "guardian_git_rev=#{ref}"]
          log "Executing ansible: #{deploy_string.join(" ")}"
          execute_and_log(deploy_string)
        end
      end
    end
  end
end
