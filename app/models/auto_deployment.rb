# An object representing when auto-deployment should occur
class AutoDeployment
  include ApiClient

  attr_accessor :commit_status, :deployment

  def initialize(deployment, commit_status)
    @commit_status = commit_status
    @deployment    = deployment
  end

  delegate :author, :branches, :default_branch, :name_with_owner, :sha,
    :to => :commit_status

  def combined_status_green?
    aggregate["state"] == "success"
  end

  def aggregate
    @aggregate ||= api.combined_status(name_with_owner, sha)
  end

  def updated_payload
    deployment.auto_deploy_payload(author, sha)
  end

  def compare
    @compare ||= api.compare(name_with_owner, deployment.sha, sha)
  end

  def ahead?
    compare.ahead_by > 0
  end

  def create_deployment
    description = "Heaven auto deploy triggered by a commit status change"
    api.create_deployment(name_with_owner, sha, :payload => updated_payload, :description => description)
  end

  def execute
    return unless combined_status_green?
    if ahead?
      Rails.logger.info "Trying to deploy #{sha}"
      create_deployment
    else
      Rails.logger.info "#{sha} isn't ahead of #{deployment.sha} and in the #{default_branch}"
    end
  end
end
