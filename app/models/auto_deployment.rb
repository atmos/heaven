class AutoDeployment
  attr_accessor :api, :commit_status, :deployment

  def initialize(deployment, commit_status, token)
    @api           = Octokit::Client.new(:access_token => token)
    @commit_status = commit_status
    @deployment    = deployment 
  end

  delegate :author, :default_branch, :name_with_owner, :sha, :to => :commit_status

  def combined_status_green?
    aggregate["state"] == "success"
  end

  def aggregate
    @aggregate ||= api.combined_status(name_with_owner, sha)
  end
 
  # 
  def updated_payload
    deployment.auto_deploy_payload(author, sha)
  end

  def compare
    @compare ||= api.compare(name_with_owner, deployment.sha, sha)
  end

  def ahead?
    compare.ahead_by > 0
  end

  def execute
    if combined_status_green?
      if ahead?
        Rails.logger.info "Trying to deploy #{sha}"
        api.create_deployment(name_with_owner, sha, :payload => updated_payload)
      else
        Rails.logger.info "#{sha} isn't ahead of #{deployment.sha} and in the #{default_branch}"
      end
    end
  end
end
