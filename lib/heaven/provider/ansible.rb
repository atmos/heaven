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
        return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

        unless File.exist?(checkout_directory)
          log "Cloning #{repository_url} into #{checkout_directory}"
          execute_and_log(["git", "clone", clone_url, checkout_directory])
        end


        Dir.chdir(checkout_directory) do
          log "Fetching the latest code"
          execute_and_log(%w{git fetch})
          execute_and_log(["git", "reset", "--hard", sha])

          ansible_hosts_file = "#{ansible_root}/hosts"
          ansible_site_file = "#{ansible_root}/site.yml"
          ansible_extra_vars = [
            "heaven_deploy_sha=#{sha}",
            "ansible_ssh_private_key_file=#{working_directory}/.ssh/id_rsa"
          ].join(" ")

          deploy_string = ["ansible-playbook", "-i", ansible_hosts_file, ansible_site_file,
                           "--verbose", "--extra-vars", ansible_extra_vars, "-vvvv"]
          log "Executing ansible: #{deploy_string.join(" ")}"
          execute_and_log(deploy_string, { "ANSIBLE_HOST_KEY_CHECKING" => 'false' })
        end
      end
    end
  end
end
