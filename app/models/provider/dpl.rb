module Provider
  class Dpl < DefaultProvider
    attr_accessor :last_child

    def initialize(guid, payload, token)
      super
      @name = "dpl"
    end

    def app_name
      return nil unless custom_payload_config
      environment == "staging" ?
        custom_payload_config['heroku_staging_name'] :
        custom_payload_config['heroku_name']
    end

    def execute_and_log(cmds)
      @last_child = POSIX::Spawn::Child.new(*cmds)
      log_stdout(last_child.out)
      log_stderr(last_child.err)
      last_child
    end

    def log(line)
      Rails.logger.info "#{app_name}-#{guid}: #{line}"
    end

    def heroku_username
      ENV['HEROKU_USERNAME']
    end

    def heroku_password
      ENV['HEROKU_PASSWORD']
    end

    def heroku_api_key
      ENV['HEROKU_API_KEY']
    end

    def dpl_path
      heroku_dpl = "/app/vendor/bundle/bin/dpl"
      if File.exists?(heroku_dpl)
        heroku_dpl
      else
        "bin/dpl"
      end
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
        log "Pushing to heroku"
        deploy_string = [ "#{dpl_path}", "--provider=heroku", "--strategy=git",
                          "--api-key=#{heroku_api_key}",
                          "--username=#{heroku_username}", "--password=#{heroku_password}",
                          "--app=#{app_name}"]
        execute_and_log(deploy_string)
      end
    end

    def setup
      unless File.exists?(working_directory)
        FileUtils.mkdir_p working_directory
      end

      output.create
      status.output = output.url
      status.pending!
    end

    def completed?
      @status.completed?
    end

    def notify 
      output.update(File.read(stdout_file), File.read(stderr_file))
      if last_child.success?
        status.success!
      else
        status.failure!
      end
    end
  end
end
