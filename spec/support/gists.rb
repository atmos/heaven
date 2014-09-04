module Gists
  def stub_gists
    request_body = {
      "files"    => {
        "public" => false,
        "stdout" => { "content" => "Deployment 721 pending" },
        "description" => "Heaven number 721 for zero-fucks-hubot"
      }
    }.to_json

    stub_request(:post, "https://api.github.com/gists")
      .with(:body => request_body, :headers => { "Authorization" => "token <unknown>" })
      .to_return(:status => 200, :body => double("id" => "cd520d99c3087f2d18b4"))

    stub_request(:patch, "https://api.github.com/gists/cd520d99c3087f2d18b4")
      .to_return(:status => 200, :body => "", :headers => {})
  end

  ::RSpec.configure do |config|
    config.include self
  end
end
