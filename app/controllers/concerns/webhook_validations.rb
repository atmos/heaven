# A bunch of validations for incoming webhooks to ensure github is sending them
module WebhookValidations
  extend ActiveSupport::Concern

  def verify_incoming_webhook_address!
    if valid_incoming_webhook_address?
      true
    else
      render :status => 404, :json => "{}"
    end
  end

  def valid_incoming_webhook_address?
    if Octokit.api_endpoint == "https://api.github.com/"
      Validator.new(request.ip).valid?
    else
      true
    end
  end

  # A class to validate if a given ip is coming from GitHub.
  class Validator
    include ApiClient
    attr_accessor :ip

    def initialize(ip)
      @ip = ip
    end

    def valid?
      hook_source_ips.any? { |block| IPAddr.new(block).include?(ip) }
    end

    private

    VERIFIER_KEY = "hook-sources-#{Rails.env}"

    def source_key
      VERIFIER_KEY
    end

    def default_ttl
      %w{staging production}.include?(Rails.env) ? 60 : 2
    end

    def meta_info
      @meta_info ||= Heaven.redis.get(source_key)
    end

    def hook_source_ips
      if meta_info
        JSON.parse(meta_info)
      else
        addresses = oauth_client_api.get("/meta").hooks
        Heaven.redis.set(source_key, JSON.dump(addresses))
        Heaven.redis.expire(source_key, default_ttl)
        Rails.logger.info "Refreshed GitHub hook sources"
        addresses
      end
    end
  end
end
