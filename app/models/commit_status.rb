# An object representing a commit status event from GitHub
class CommitStatus
  include ApiClient

  attr_accessor :guid, :payload

  def initialize(guid, payload)
    @guid    = guid
    @payload = payload
  end

  def data
    @data ||= JSON.parse(payload)
  end

  def successful?
    state == "success"
  end

  def sha
    data["sha"][0..7]
  end

  def state
    data["state"]
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

  def author
    data["commit"]["commit"]["author"]["login"]
  end

  def run!
    return unless successful?
    if default_branch?
      Deployment.latest_for_name_with_owner(name_with_owner).each do |deployment|
        Rails.logger.info "tryna deploy #{name_with_owner}@#{sha} to #{deployment.environment}"
        AutoDeployment.new(deployment, self).execute
      end
    else
      branch = branches && branches.any? && branches.first["name"]
      Rails.logger.info "Ignoring commit status(#{state}) for #{name_with_owner}+#{branch}@#{sha}"
    end
  end
end
