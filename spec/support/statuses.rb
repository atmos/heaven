module Statuses
  def stub_deploy_statuses
    stub_request(:post, "https://api.github.com/repos/github/oiran/deployments/statuses").
      with(:body => "{\"target_url\":\"https://gist.github.com/cd520d99c3087f2d18b4\",\"state\":\"pending\"}").
      to_return(:status => 200, :body => "", :headers => {})

    stub_request(:post, "https://api.github.com/repos/github/oiran/deployments/statuses").
      with(:body => "{\"target_url\":\"https://gist.github.com/cd520d99c3087f2d18b4\",\"state\":\"success\"}")
  end

  ::RSpec.configure do |config|
    config.include self
  end
end
