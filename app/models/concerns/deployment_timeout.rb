# A module to handle deployment timeouts
module DeploymentTimeout
  extend ActiveSupport::Concern

  def timeout
    Integer(ENV["DEPLOYMENT_TIMEOUT"] || "300")
  end

  def deployment_time_elapsed
    (Time.now - deployment_start_time).ceil
  end

  def deployment_time_remaining
    timeout - deployment_time_elapsed
  end

  def deployment_start_time
    @deployment_start_time || Time.now
  end

  def start_deployment_timeout!
    @deployment_start_time = Time.now
  end
end
