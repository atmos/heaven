# A class to validate if a given ip is coming from GitHub.
class GithubSourceValidator
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
