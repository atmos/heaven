module Provider
  class Capistrano < DefaultProvider
    attr_accessor :last_child

    def initialize(guid, payload)
      super
      @name = "capistrano"
    end

    def cap_path
      cap_dpl = "/app/vendor/bundle/bin/cap"
      if File.exists?(heroku_dpl)
        cap_dpl
      else
        "bin/cap"
      end
    end

    def task
      name = custom_payload && custom_payload['task'] || 'deploy'
      unless name =~ /deploy(?:\:[\w+:]+)?/
        raise StandardError "Invalid capistrano taskname: #{name.inspect}"
      end
      name
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
        log "Executing capistrano"
        deploy_string = [ cap_path, environment, task ]
        execute_and_log(deploy_string)
      end
    end

    def setup
      super
      unless File.exists?(working_directory)
        FileUtils.mkdir_p working_directory
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
