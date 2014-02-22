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
    @data ||= JSON.parse(@payload)
  end

  def redis
    HerokuDeploy.redis
  end

  def number
    data['id']
  end

  def run!
    redis.set("deployment:#{number}", payload)
  end

  def self.perform(event, guid, data)
    new(event, guid, data).run!
  end
end
