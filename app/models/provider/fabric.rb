module Provider
  class Fabric < DefaultProvider
    attr_accessor :last_child

    def initialize(guid, payload)
      super
      @name = "fabric"
    end

    def task
      custom_payload && custom_payload['task'] || 'deploy'
    end

    def execute_and_log(cmds)
      @last_child = POSIX::Spawn::Child.new({"HOME"=>working_directory},*cmds)
      log_stdout(last_child.out)
      log_stderr(last_child.err)
      last_child
    end

    def execute
      return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

      unless File.exists?(checkout_directory)
        log "Cloning #{repository_url} into #{checkout_directory}"
        execute_and_log(["git", "clone", clone_url, checkout_directory])
      end

      Dir.chdir(checkout_directory) do
        log "Fetching the latest code"
        execute_and_log(["git", "fetch"])
        execute_and_log(["git", "reset", "--hard", sha])
        deploy_command_format = ENV['DEPLOY_COMMAND_FORMAT'] || "fab -R %{environment} %{task}:branch_name=%{ref}"
        deploy_command = deploy_command_format % {
          :environment => environment,
          :task => task,
          :ref => ref
        }

        log "Executing fabric: #{deploy_command}"
        execute_and_log(deploy_command)
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