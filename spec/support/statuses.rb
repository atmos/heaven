module Statuses
  class StubDeploymentRel
    attr_reader :nwo, :number, :type
    def initialize(nwo, number, type)
      @nwo = nwo
      @number = number
      @type = type
    end

    def href
      "https://api.github.com/repos/#{nwo}/deployments/#{number}/#{type}"
    end
  end

  class StubDeployment
    attr_reader :nwo, :number
    def initialize(nwo, number)
      @nwo = nwo
      @number = number
    end

    def rels
      { :statuses => StubDeploymentRel.new(nwo, number, "statuses") }
    end
  end

  def stub_deploy_statuses
    stub_request(:get, "https://api.github.com/repos/atmos/my-robot/deployments/721").
      to_return(:status => 200, :body => StubDeployment.new("atmos/my-robot", 721), :headers => {})

    stub_request(:post, "https://api.github.com/repos/atmos/my-robot/deployments/721/statuses").
      with(:body => "{\"target_url\":\"https://gist.github.com/cd520d99c3087f2d18b4\",\"description\":\"Deploying from Heaven v#{Heaven::VERSION}\",\"state\":\"pending\"}").
      to_return(:status => 201, :body => {}, :headers => {})

    stub_request(:post, "https://api.github.com/repos/atmos/my-robot/deployments/721/statuses").
      with(:body => "{\"target_url\":\"https://gist.github.com/cd520d99c3087f2d18b4\",\"description\":\"Deploying from Heaven v#{Heaven::VERSION}\",\"state\":\"failure\"}").
      to_return(:status => 201, :body => {}, :headers => {})

    stub_request(:post, "https://api.github.com/repos/atmos/my-robot/deployments/721/statuses").
      with(:body => "{\"target_url\":\"https://gist.github.com/cd520d99c3087f2d18b4\",\"description\":\"Deploying from Heaven v#{Heaven::VERSION}\",\"state\":\"success\"}").
      to_return(:status => 201, :body => {}, :headers => {})
  end

  ::RSpec.configure do |config|
    config.include self
  end
end
