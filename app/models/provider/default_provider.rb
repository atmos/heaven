module Provider
  class DefaultProvider
    include ApiClient
    include LocalLogFile

    attr_accessor :guid, :name, :payload

    def initialize(guid, payload)
      @guid    = guid
      @name    = "unknown"
      @payload = payload
    end

    def data
      @data ||= JSON.parse(payload)
    end

    def output
      @output ||= Deployment::Output.new(app_name, number, guid)
    end

    def status
      @status ||= Deployment::Status.new(name_with_owner, number)
    end

    def redis
      Heaven.redis
    end

    def number
      data['id']
    end

    def name
      custom_payload_name || name_with_owner
    end

    def name_with_owner
      data['repository']['full_name']
    end

    def sha
      data['sha'][0..7]
    end

    def ref
      data['ref']
    end

    def environment
      data['environment']
    end

    def repository_url
      data['repository']['clone_url']
    end

    def default_branch
      data['repository']['default_branch']
    end

    def clone_url
      uri = Addressable::URI.parse(repository_url)
      uri.user = github_token
      uri.password = ""
      uri.to_s
    end

    def custom_payload
      @custom_payload ||= data['payload']
    end

    def custom_payload_name
      custom_payload && custom_payload['name']
    end

    def custom_payload_config
      custom_payload && custom_payload['config']
    end

    def custom_payload_before_deploy
      custom_payload_config && custom_payload_config['before_deploy']
    end

    def custom_payload_pre_deploy
      custom_payload_config && custom_payload_config['pre_deploy']
    end

    def custom_payload_post_deploy
      custom_payload_config && custom_payload_config['post_deploy']
    end

    def custom_payload_before_deploy
      custom_payload_config && custom_payload_config['before_deploy']
    end

    def custom_payload_after_deploy
      custom_payload_config && custom_payload_config['after_deploy']
    end

    def setup
      output.create
      status.output = output.url
      status.pending!
    end

    def completed?
      status.completed?
    end

    def execute_and_log(cmd)
      child = POSIX::Spawn::Child.new(cmd)
      output.outs["stdout #{cmd}"] = child.out
      output.outs["stderr #{cmd}"] = child.err
      child
    end

    def execute_commands(commands)
      commands.each do |cmd|
        execute_and_log cmd
      end
    end

    def before_deploy
      Rails.logger.info "Execute before deploy scripts #{custom_payload_before_deploy}"
      execute_commands(custom_payload_before_deploy || [])
    end

    def pre_deploy
      Rails.logger.info "Execute pre-deploy scripts #{custom_payload_pre_deploy}"
      execute_commands(custom_payload_pre_deploy || [])
    end

    def post_deploy
      Rails.logger.info "Execute post-deploy scripts #{custom_payload_post_deploy}"
      execute_commands(custom_payload_post_deploy || [])
    end

    def after_deploy
      Rails.logger.info "Execute after deploy scripts #{custom_payload_after_deploy}"
      execute_commands(custom_payload_after_deploy || [])
    end

    def execute
      warn "Heaven Provider(#{name}) didn't implement execute"
    end

    def notify
      warn "Heaven Provider(#{name}) didn't implement notify"
    end

    def record
      Deployment.create(:custom_payload  => JSON.dump(custom_payload),
                        :environment     => environment,
                        :guid            => guid,
                        :name            => name,
                        :name_with_owner => name_with_owner,
                        :output          => output.url,
                        :ref             => ref,
                        :sha             => sha)
    end

    def timeout
      Integer(ENV['DEPLOYMENT_TIMEOUT'] || '300')
    end

    def run!
      before_deploy
      Timeout.timeout(timeout) do
        setup
        pre_deploy
        execute
        post_deploy
        notify
        record
      end
      after_deploy
    rescue StandardError => e
      Rails.logger.info e.message
      Rails.logger.info caller
    ensure
      status.failure! unless completed?
    end
  end
end
