class Deployment
  class Status
    attr_accessor :number, :nwo, :output, :token
    def initialize(token, nwo, number)
      @nwo    = nwo
      @token  = token
      @number = number
    end

    def api
      @api ||= Octokit::Client.new(:access_token => @token)
    end

    def url
      "https://api.github.com/repos/#{nwo}/deployments/#{number}"
    end

    def description
      "Deploying from Heaven v#{Heaven::VERSION}"
    end

    def payload
      {:target_url => output, :description => description}
    end

    def pending!
      api.create_deployment_status(url, 'pending', payload)
    end

    def complete!(successful)
      state = successful ? "success" : "failure"
      api.create_deployment_status(url, state, payload)
    end
  end
end
