class Receiver
  @queue = :events

  attr_accessor :event, :guid, :last_child, :payload, :remote_ip, :token

  def initialize(remote_ip, event, guid, payload)
    @guid      = guid
    @event     = event
    @token     = ENV['GITHUB_DEPLOY_TOKEN'] || '<unknown>'
    @payload   = payload
    @remote_ip = remote_ip
  end

  def self.perform(remote_ip, event, guid, data)
    new(remote_ip, event, guid, data).run!
  end

  def valid_remote_ip?
    return true if ["127.0.0.1", "0.0.0.0"].include?(remote_ip)
    ip_blocks = api.get("/meta").hooks
    ip_blocks.any? { |block| IPAddr.new(block).include?(remote_ip) }
  end

  def redis
    Heaven.redis
  end

  def api
    @api ||= Octokit::Client.new(:access_token => token)
  end

  def run!
    return unless valid_remote_ip?
    redis.set("deployment:#{guid}", payload)

    if event == "deployment"
      Deployment.new(guid, payload, token).run!
    else
      Rails.logger.info "Unhandled event type, #{event}."
    end
  end
end
