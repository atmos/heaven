class CommitStatus
  attr_accessor :guid, :payload, :token

  def initialize(guid, payload, token)
    @guid    = guid
    @token   = token
    @payload = payload
  end

  def run!
  end
end
