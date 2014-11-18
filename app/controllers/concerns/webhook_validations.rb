# A bunch of validations for incoming webhooks to ensure github is sending them
module WebhookValidations
  extend ActiveSupport::Concern

  def verify_incoming_webhook_address!
    if valid_incoming_webhook_address?
      true
    else
      render :json => {}, :status => :forbidden
    end
  end

  def valid_incoming_webhook_address?
    if Octokit.api_endpoint == "https://api.github.com/"
      GithubSourceValidator.new(request.ip).valid?
    else
      true
    end
  end
end
