module ApiClient
  extend ActiveSupport::Concern

  def github_token
    ENV["GITHUB_TOKEN"] || "<unknown>"
  end

  def github_client_id
    ENV["GITHUB_CLIENT_ID"] || "<unknown-client-id>"
  end

  def github_client_secret
    ENV["GITHUB_CLIENT_SECRET"] || "<unknown-client-secret>"
  end

  def api
    @api ||= Octokit::Client.new(:access_token => github_token)
  end

  def oauth_client_api
    @oauth_client_api ||= Octokit::Client.new(
      :client_id     => github_client_id,
      :client_secret => github_client_secret
    )
  end
end
