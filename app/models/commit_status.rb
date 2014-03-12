class CommitStatus
  attr_accessor :guid, :payload, :token

  def initialize(guid, payload, token)
    @guid    = guid
    @token   = token
    @payload = payload
  end

  def data
    @data ||= JSON.parse(payload)
  end

  def api
    @api ||= Octokit::Client.new(:access_token => token)
  end

  def redis
    Heaven.redis
  end

  def default_branch?
  end

  def run!
  end
end
