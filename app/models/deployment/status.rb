# Top-level class for Deployments.
class Deployment
  # A GitHub DeploymentStatus.
  class Status
    include ApiClient

    attr_reader :completed

    attr_accessor :description, :number, :nwo, :output
    def initialize(nwo, number)
      @nwo         = nwo
      @number      = number
      @completed   = false
      @description = "Deploying from Heaven v#{Heaven::VERSION}"
    end

    def url
      "https://api.github.com/repos/#{nwo}/deployments/#{number}"
    end

    def payload
      { "target_url"  => output, "description" => description }
    end

    def pending!
      api.create_deployment_status(url, "pending", payload)
    end

    def success!
      api.create_deployment_status(url, "success", payload)
      @completed = true
    end

    def failure!
      api.create_deployment_status(url, "failure", payload)
      @completed = true
    end

    def error!
      api.create_deployment_status(url, "error", payload)
      @completed = true
    end
  end
end
