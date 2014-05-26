class Receiver
  @queue = :events

  attr_accessor :event, :guid, :payload

  def initialize(event, guid, payload)
    @guid      = guid
    @event     = event
    @payload   = payload
  end

  def self.perform(event, guid, payload)
    new(event, guid, payload).run!
  end

  def run!
    if event == "deployment"
      Resque.enqueue(Heaven::Jobs::Deployment, guid, payload)
    elsif event == "deployment_status"
      Resque.enqueue(Heaven::Jobs::DeploymentStatus, guid, payload)
    elsif event == "status"
      Resque.enqueue(Heaven::Jobs::Status, guid, payload)
    else
      Rails.logger.info "Unhandled event type, #{event}."
    end
  end
end
