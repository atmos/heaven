module Meta
  def stub_meta
    body = JSON.load(fixture_data("meta"))

    stub_request(:get, "https://api.github.com/meta?client_id=%3Cunknown-client-id%3E&client_secret=%3Cunknown-client-secret%3E").
      with(:headers => {'Accept'=>'application/vnd.github.v3+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Octokit Ruby Gem 3.1.0'}).
      to_return(:status => 200, :body => double("hooks" => body["hooks"]))
  end

  ::RSpec.configure do |config|
    config.include self
  end
end
