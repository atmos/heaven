class Deployment
  attr_accessor :guid, :payload, :token, :last_child

  def initialize(guid, payload, token)
    @guid    = guid
    @token   = token
    @payload = payload
  end

  def data
    @data ||= JSON.parse(payload)
  end

  def api
    @api ||= Octokit::Client.new(:access_token => token)
  end

  def redis
    Heaven.redis
  end

  def number
    data['id']
  end

  def repository_url
    data['repository']['clone_url']
  end

  def name_with_owner
    data['repository']['full_name']
  end

  def custom_payload
    @custom_payload ||= data['payload']
  end

  def custom_payload_config
    custom_payload && custom_payload['config']
  end

  def environment
    custom_payload && custom_payload.fetch("environment", "production")
  end

  def app_name
    return nil unless custom_payload_config
    environment == "staging" ?
      custom_payload_config['heroku_staging_name'] :
      custom_payload_config['heroku_name']
  end

  def default_branch
    data['repository']['default_branch']
  end

  def sha
    data['sha'][0..7]
  end

  def clone_url
    uri = Addressable::URI.parse(repository_url)
    uri.user = token
    uri.password = ""
    uri.to_s
  end

  def log_stdout(out)
    File.open(stdout_file, 'a') { |f| f.write(out) }
  end

  def log_stderr(err)
    File.open(stderr_file, 'a') { |f| f.write(err) }
  end

  def execute_and_log(cmds)
    @last_child = POSIX::Spawn::Child.new(*cmds)
    log_stdout(last_child.out)
    log_stderr(last_child.err)
    last_child
  end

  def working_directory
    @working_directory ||= "/tmp/" + \
      Digest::SHA1.hexdigest([name_with_owner, token].join)
  end

  def checkout_directory
    "#{working_directory}/checkout"
  end

  def stdout_file
    "#{working_directory}/stdout.#{guid}.log"
  end

  def stderr_file
    "#{working_directory}/stderr.#{guid}.log"
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

  def execute_deployment
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

  def deploy_output
    @deploy_output ||= Deployment::Output.new(app_name, number, guid, token)
  end

  def deploy_status
    @deploy_status ||= Deployment::Status.new(token, name_with_owner, number)
  end

  def deploy_started
    deploy_output.create
    deploy_status.output = deploy_output.url
    deploy_status.pending!
  end

  def deploy_completed(successful)
    deploy_output.update(File.read(stdout_file), File.read(stderr_file))
    deploy_status.complete!(successful)
  end

  def run!
    deploy_started

    unless File.exists?(working_directory)
      FileUtils.mkdir_p working_directory
    end
    execute_deployment
    deploy_completed(last_child.success?)
  end
end
