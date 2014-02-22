module Gists
  def stub_gists
    stub_request(:post, "https://api.github.com/gists").
      with(:body => "{\"files\":{\"clone\":{\"content\":\"Deployment 721 pending\"}},\"public\":false,\"description\":\"HerokuDeploy number 721 for zero-fucks-hubot\"}",
           :headers => { 'Authorization'=>'token <unknown>'}).
      to_return(:status => 200, :body => double('id' => "cd520d99c3087f2d18b4"))

    stub_request(:patch, "https://api.github.com/gists/cd520d99c3087f2d18b4").
      to_return(:status => 200, :body => "", :headers => {})
  end

  ::RSpec.configure do |config|
    config.include self
  end
end
