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

  def successful?
    data["state"] == "success"
  end

  def branches
    @branches ||= data["branches"]
  end

  def default_branch
    data["repository"]["default_branch"]
  end

  def default_branch?
    branches.any? { |branch| branch["name"] == default_branch }
  end

  def name_with_owner
    data["full_name"]
  end

  def auto_deployable?
    default_branch? && successful?
  end

  def run!
    if auto_deployable?
      Rails.logger.info "Finna tryna deploy #{name_with_owner}@#{sha}"
    else
      Rails.logger.info "Ignoring commit status for #{name_with_owner}@#{sha}"
    end
  end
end
