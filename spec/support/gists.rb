module Gists
  def stub_gists
    stub_request(:post, "https://api.github.com/gists").
      with(:body => "{\"files\":{\"clone\":{\"content\":\"Deployment oiran pending\"}},\"public\":false,\"description\":\"Oiran deploy number oiran for -b6bac500-3694-11e3-80c1-d406c1a7dfdd\"}",
           :headers => { 'Authorization'=>'token <secret>'}).
      to_return(:status => 200, :body => double('id' => "cd520d99c3087f2d18b4"))

    stub_request(:patch, "https://api.github.com/gists/cd520d99c3087f2d18b4").
      to_return(:status => 200, :body => "", :headers => {})
  end

  ::RSpec.configure do |config|
    config.include self
  end
end
