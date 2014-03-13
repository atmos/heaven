class Receiver
  @queue = :events

  attr_accessor :event, :guid, :last_child, :payload, :token

  def initialize(event, guid, payload)
    @guid      = guid
    @event     = event
    @token     = ENV['GITHUB_DEPLOY_TOKEN'] || '<unknown>'
    @payload   = payload
  end

  def self.perform(event, guid, data)
    new(event, guid, data).run!
  end

  def redis
    Heaven.redis
  end

  def api
    @api ||= Octokit::Client.new(:access_token => token)
  end

  def run!
    if event == "deployment"
      Deployment.new(guid, payload, token).run!
    elsif event == "status"
      CommitStatus.new(guid, payload, token).run!
    else
      Rails.logger.info "Unhandled event type, #{event}."
    end
  end
end
