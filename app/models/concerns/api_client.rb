# A module to include for easy access to the GitHub API
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

  def github_api_endpoint
    ENV["OCTOKIT_API_ENDPOINT"] || "https://api.github.com/"
  end

  def api
    @api ||= Octokit::Client.new(:access_token => github_token,
                                 :api_endpoint => github_api_endpoint)
  end

  def oauth_client_api
    @oauth_client_api ||= Octokit::Client.new(
      :client_id     => github_client_id,
      :client_secret => github_client_secret,
      :api_endpoint  => github_api_endpoint
    )
  end
end
