class Receiver
  @queue = :events

  attr_accessor :event, :guid, :payload, :token

  def initialize(event, guid, payload)
    @guid      = guid
    @event     = event
    @token     = ENV['GITHUB_DEPLOY_TOKEN'] || '<unknown>'
    @payload   = payload
  end

  def self.perform(event, guid, data)
    new(event, guid, data).run!
  end

  def run!
    if event == "deployment"
      provider = Provider.from(guid, payload, token)
      provider.run!
    elsif event == "status"
      CommitStatus.new(guid, payload, token).run!
    else
      Rails.logger.info "Unhandled event type, #{event}."
    end
  end
end
