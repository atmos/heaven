module WebhookValidations
  extend ActiveSupport::Concern

  def verify_incoming_webhook_address!
    unless valid_incoming_webhook_address?
      render :status => 404, :json => "{}"
    end
  end

  def valid_incoming_webhook_address?
    Validator.new(request.ip).valid?
  end

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
        %w(staging production).include?(Rails.env) ? 60 : 2
      end

      def hook_source_ips
        if addresses = Heaven.redis.get(source_key)
          JSON.parse(addresses)
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
