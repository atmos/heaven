# A module to handle deployment timeouts
module DeploymentTimeout
  extend ActiveSupport::Concern

  included do
    attr_reader :start_time
  end

  def timeout
    Integer(ENV["DEPLOYMENT_TIMEOUT"] || "300")
  end

  def time_elapsed
    ((start_time || Time.now) - Time.now).ceil
  end

  def time_remaining
    timeout - time_elapsed
  end

  def start_deploy_timeout!
    @start_time = Time.now
  end
end
