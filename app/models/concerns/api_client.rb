module ApiClient
  extend ActiveSupport::Concern

  def github_token
    @github_token = ENV['GITHUB_DEPLOY_TOKEN'] || '<unknown>'
  end

  def api
    @api ||= Octokit::Client.new(:access_token => github_token)
  end
end
