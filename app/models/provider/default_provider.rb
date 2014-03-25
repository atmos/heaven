module Provider
  class DefaultProvider
    include Deployment::LogFile

    attr_accessor :guid, :name, :payload, :token

    def initialize(guid, payload, token)
      @guid    = guid
      @name    = "unknown"
      @token   = token
      @payload = payload
    end

    def data
      @data ||= JSON.parse(payload)
    end

    def api
      @api ||= Octokit::Client.new(:access_token => token)
    end

    def output
      @output ||= Deployment::Output.new(app_name, token, number, guid)
    end

    def status
      @status ||= Deployment::Status.new(name_with_owner, token, number)
    end

    def redis
      Heaven.redis
    end

    def number
      data['id']
    end

    def name_with_owner
      data['repository']['full_name']
    end

    def sha
      data['sha'][0..7]
    end

    def repository_url
      data['repository']['clone_url']
    end

    def default_branch
      data['repository']['default_branch']
    end

    def clone_url
      uri = Addressable::URI.parse(repository_url)
      uri.user = token
      uri.password = ""
      uri.to_s
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

    def run!
      setup
      execute
      notify
    rescue StandardError => e
      Rails.logger.info e.message
    ensure
      status.failure! unless completed?
    end
  end
end
