# Top-level class for Deployments.
class Deployment
  # A GitHub DeploymentStatus.
  class Status
    include ApiClient

    attr_accessor :description, :number, :nwo, :output, :completed
    alias_method :completed?, :completed

    def initialize(nwo, number)
      @nwo         = nwo
      @number      = number
      @completed   = false
      @description = "Deploying from Heaven v#{Heaven::VERSION}"
    end

    class << self
      def deliveries
        @deliveries ||= []
      end
    end

    def url
      "#{Octokit.api_endpoint}repos/#{nwo}/deployments/#{number}"
    end

    def payload
      { "target_url" => output, "description" => description }
    end

    def pending!
      create_status(:status => "pending", :completed => false)
    end

    def success!
      create_status(:status => "success")
    end

    def failure!
      create_status(:status => "failure")
    end

    def error!
      create_status(:status => "error")
    end

    private

    def create_status(status:, completed: true)
      if Heaven.testing?
        self.class.deliveries << payload.merge("status" => status)
      else
        api.create_deployment_status(url, status, payload)
      end

      @completed = completed
    end
  end
end
