module Heaven
  # Top-level module for providers.
  module Provider
    # The capistrano provider.
    class Waysact < DefaultProvider
      def initialize(guid, payload)
        super
        @name = "waysact"
      end

      def ansible_root
        "#{checkout_directory}"
      end

      def execute
        return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

        unless File.exist?(checkout_directory)
          playbook_repository_url = "https://#{ENV['GITHUB_USER']}:#{ENV["GITHUB_TOKEN"]}@github.com/waysact/waysact-ansible.git"
          log "Cloning #{playbook_repository_url} into #{checkout_directory}"
          execute_and_log(["git", "clone", playbook_repository_url, checkout_directory])
        end

        Dir.chdir(checkout_directory) do
          log "Fetching the latest code"
          execute_and_log(%w{git fetch})
          execute_and_log(["git", "reset", "--hard"])

          ansible_hosts_file = "#{ansible_root}/inventories/vagrant"
          ansible_site_file = "#{ansible_root}/site.yml"
          ansible_extra_vars = [
            "heaven_deploy_sha=#{sha}",
            "ansible_ssh_private_key_file=#{working_directory}/.ssh/id_rsa"
          ].join(" ")

          ansible_vault_password = ENV["ANSIBLE_VAULT_PASSWORD"]
          # ansible-vault doesn't have an argument to read the vault password
          # directly insteas an executable which should output the password can
          # be specified with the --vault-password-file argument.  The idea to
          # use cat to read the password from stdin came from the ansible
          # developers mailing list:
          # https://groups.google.com/d/msg/ansible-devel/1vFc3y6Ogto/ne0xKq5pQXcJ
          deploy_string = ["ansible-playbook", "-i", ansible_hosts_file, ansible_site_file, "--tags", "deploy", "-u", "vagrant",
                           "--verbose", "--extra-vars", ansible_extra_vars, "--extra-vars", "@vaults/vagrant_secrets.yml",
                           "--vault-password-file=/bin/cat", "-vvvv"]
          log "Executing ansible: #{deploy_string.join(" ")}"
          execute_and_log(deploy_string,  { "ANSIBLE_HOST_KEY_CHECKING" => "false" }, ansible_vault_password)
        end
      end
    end
  end
end
