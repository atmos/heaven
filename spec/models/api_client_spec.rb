require "spec_helper"

describe ApiClient do
  class ExampleClass
    extend ApiClient
  end

  def octokit_request_headers
    {
      "Accept"          => "application/vnd.github.v3+json",
      "User-Agent"      => "Octokit Ruby Gem #{Octokit::VERSION}",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
    }
  end

  describe "#api" do
    it "#api uses #github_token to auth requests" do
      ENV["GITHUB_TOKEN"] = "secret"
      stub_request(:get, "https://api.github.com/user")
        .with(:headers => octokit_request_headers)
        .to_return(:status => 200, :body => "atmos")
      expect(ExampleClass.api.user).to eql("atmos")
    end
  end

  describe "#oauth_client_api" do
    it "#oauth_client_api uses #github_client_id and #github_client_secret" do
      ENV["GITHUB_CLIENT_ID"]     = "id"
      ENV["GITHUB_CLIENT_SECRET"] = "secret"

      stub_request(:get, "https://api.github.com/meta?client_id=id&client_secret=secret")
        .with(:headers => octokit_request_headers)
        .to_return(:status => 200, :body => "ok")

      expect(ExampleClass.oauth_client_api.meta).to eql("ok")
    end
  end
end
