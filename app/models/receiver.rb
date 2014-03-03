class Receiver
  @queue = :events

  attr_accessor :event, :guid, :payload, :token

  def initialize(event, guid, payload)
    @guid    = guid
    @event   = event
    @token   = ENV['GITHUB_DEPLOY_TOKEN'] || '<unknown>'
    @payload = payload
  end

  def data
    @data ||= JSON.parse(payload)
  end

  def redis
    Heaven.redis
  end

  def number
    data['id']
  end

  def self.perform(event, guid, data)
    new(event, guid, data).run!
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
    environment == "staging" ? custom_payload_config['heroku_staging_name'] : custom_payload_config['heroku_name']
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

  def execute_and_log(cmd)
    `#{cmd} >> #{stdout_file} 2>> #{stderr_file}`
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

  def run!
    redis.set("deployment:#{number}", payload)

    if event == "deployment"
      deploy!
    else
      log "Unhandled event type, #{event}."
    end
  end

  def deploy_output
    @deploy_output ||= Output.new(app_name, number, guid, token)
  end

  def deploy_status
    @deploy_status ||= Status.new(token, name_with_owner, number)
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

  def deploy!
    deploy_started

    unless File.exists?(working_directory)
      FileUtils.mkdir_p working_directory
    end
    execute_deployment
    deploy_completed($?.success?)
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
    return execute_and_log("true") if Rails.env.test?

    unless File.exists?(checkout_directory)
      log "Cloning #{repository_url} into #{checkout_directory}"
      log `git clone #{clone_url} #{checkout_directory} 2>&1`
    end

    Dir.chdir(checkout_directory) do
      log "Fetching the latest code"
      execute_and_log("git fetch && git reset --hard #{sha}")
      log "Pushing to heroku"
      deploy_string = [ "#{dpl_path}", "--provider=heroku", "--strategy=git",
                        "--api-key=#{heroku_api_key}",
                        "--username=#{heroku_username}", "--password=#{heroku_password}",
                        "--app=#{app_name}"].join(" ")
      execute_and_log(deploy_string)
    end
  end
end
