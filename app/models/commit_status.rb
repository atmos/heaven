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

  # This Commit Status succeeded
  def successful?
    state == "success"
  end

  # All Commit Statuses across contexts were successful
  def green?
    aggregate["state"] == "success"
  end

  def sha
    data["sha"]
  end

  def state
    data["state"]
  end

  def aggregate
    @aggregate ||= api.get "/repos/#{name_with_owner}}/commits/#{data["sha"]}/status"
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
    data["repository"]["full_name"]
  end

  def auto_deployable?
    default_branch? && successful?
  end

  def run!
    if auto_deployable?
      Rails.logger.info "Finna tryna deploy #{name_with_owner}@#{sha}"
    else
      Rails.logger.info "Ignoring commit status(#{state}) for #{name_with_owner}@#{sha}"
    end
  end
end
