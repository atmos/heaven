class Receiver
  @queue = :events

  attr_accessor :event, :guid, :payload

  def initialize(event, guid, payload)
    @guid      = guid
    @event     = event
    @payload   = payload
  end

  def self.perform(event, guid, data)
    new(event, guid, data).run!
  end

  def run!
    if event == "deployment"
      provider = Provider.from(guid, payload)
      provider.run!
    elsif event == "deployment_status"
      notifier = Heaven::Notifier.for(payload)
      notifier.post! if notifier
    elsif event == "status"
      CommitStatus.new(guid, payload).run!
    else
      Rails.logger.info "Unhandled event type, #{event}."
    end
  end
end
