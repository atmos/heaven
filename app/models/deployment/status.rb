class Deployment
  class Status
    include ApiClient

    attr_accessor :number, :nwo, :output
    def initialize(nwo, number)
      @nwo       = nwo
      @number    = number
      @completed = false
    end

    def url
      "https://api.github.com/repos/#{nwo}/deployments/#{number}"
    end

    def description
      "Deploying from Heaven v#{Heaven::VERSION}"
    end

    def payload
      { 'target_url'  => output, 'description' => description }
    end

    def pending!
      api.create_deployment_status(url, 'pending', payload)
    end

    def success!
      api.create_deployment_status(url, "success", payload)
      @completed = true
    end

    def failure!
      api.create_deployment_status(url, "failure", payload)
      @completed = true
    end

    def completed?
      @completed
    end
  end
end
