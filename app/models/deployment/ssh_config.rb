class Deployment
  class SshConfig
    attr_accessor :root

    def initialize(root)
      @root = root
    end

    def path
      "#{root}/.ssh"
    end

    def config_path
      "#{path}/config"
    end

    def private_key_path
      "#{path}/id_rsa"
    end

    def git_ssh_path
      "#{root}/git-ssh"
    end

    def configure!
      FileUtils.mkdir_p path
      FileUtils.chmod_R 0700, path

      File.open(private_key_path, "w", 0600) do |fp|
        fp.puts(ENV["DEPLOYMENT_PRIVATE_KEY"].split('\n'))
      end

      File.open(config_path, "w", 0600) do |fp|
        fp.puts("StrictHostKeyChecking no\nUserKnownHostsFile /dev/null\nHost heroku\n\tHostname heroku.com\n\tIdentityFile #{private_key_path}\n\tUser git")
      end

      File.open(git_ssh_path, "w", 0755) do |fp|
        fp.write <<-EOF
  #!/bin/sh

  export HOME=#{root}
  /usr/bin/ssh -F #{config_path} "$@"
        EOF
      end
    end
  end
end
