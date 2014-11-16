# A class to handle incoming webhooks
class Receiver
  @queue = :events

  attr_accessor :event, :guid, :data

  def initialize(event, guid, data)
    @guid  = guid
    @event = event
    @data  = data
  end

  def self.perform(event, guid, data)
    receiver = new(event, guid, data)

    if receiver.active_repository?
      receiver.run!
    else
      Rails.logger.info "Repository is not configured to deploy: #{receiver.full_name}"
    end
  end

  def full_name
    data["repository"] && data["repository"]["full_name"]
  end

  def active_repository?
    if data["repository"]
      name  = data["repository"]["name"]
      owner = data["repository"]["owner"]["login"]
      repository = Repository.find_or_create_by(:name => name, :owner => owner)
      repository.active?
    else
      false
    end
  end

  def run_deployment!
    return if LockReceiver.new(data).run!

    if Heaven::Jobs::Deployment.locked?(guid, data)
      Rails.logger.info "Deployment locked for: #{Heaven::Jobs::Deployment.identifier(guid, data)}"
      Resque.enqueue(Heaven::Jobs::LockedError, guid, data)
    else
      Resque.enqueue(Heaven::Jobs::Deployment, guid, data)
    end
  end

  def run!
    if event == "deployment"
      run_deployment!
    elsif event == "deployment_status"
      Resque.enqueue(Heaven::Jobs::DeploymentStatus, data)
    elsif event == "status"
      Resque.enqueue(Heaven::Jobs::Status, guid, data)
    else
      Rails.logger.info "Unhandled event type, #{event}."
    end
  end
end
