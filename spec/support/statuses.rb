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

  def deployment_url(path = "")
    "https://api.github.com/repos/atmos/my-robot/deployments/721#{path}"
  end

  def stub_deploy_statuses
    deployment_results = {
      :body => StubDeployment.new("atmos/my-robot", 721),
      :status => 200,
      :headers => {}
    }
    stub_request(:get, deployment_url)
      .to_return(deployment_results)

    extra_params = {
      "target_url"  => "https://gist.github.com/cd520d99c3087f2d18b4",
      "description" => "Deploying from Heaven v#{Heaven::VERSION}"
    }

    stub_request(:post, deployment_url("/statuses"))
      .with(:body => extra_params.merge("state" => "pending").to_json)
      .to_return(:status => 201, :body => {}, :headers => {})

    stub_request(:post, deployment_url("/statuses"))
      .with(:body => extra_params.merge("state" => "failure").to_json)
      .to_return(:status => 201, :body => {}, :headers => {})

    stub_request(:post, deployment_url("/statuses"))
      .with(:body => extra_params.merge("state" => "success").to_json)
      .to_return(:status => 201, :body => {}, :headers => {})
  end

  ::RSpec.configure do |config|
    config.include self
  end
end
