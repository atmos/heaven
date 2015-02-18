module MetaHelper
  def stub_meta
    request_params = {
      "headers" => {
        "Accept"          => "application/vnd.github.v3+json",
        "User-Agent"      => "Octokit Ruby Gem #{Octokit::VERSION}",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
      }
    }

    get_url = "https://api.github.com/meta?client_id=%3Cunknown-client-id%3E&client_secret=%3Cunknown-client-secret%3E"

    stub_request(:get, get_url).with(request_params)
      .to_return(:status => 200, :body => double("hooks" => ["192.30.252.0/22"]))
  end
end
