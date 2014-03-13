class Verifier
  VERIFIER_KEY = "hook-sources-#{Rails.env}"

  def key
    VERIFIER_KEY
  end

  def ttl
    %w(staging production).include?(Rails.env) ? 60 : 2
  end

  def hook_source_ips
    if addresses = Heaven.redis.get(key)
      JSON.parse(addresses)
    else
      addresses = Octokit::Client.new.get("/meta").hooks
      Heaven.redis.set(key, JSON.dump(addresses))
      Heaven.redis.expire(key, ttl)
      Rails.logger.info "Refreshed GitHub hook sources"
      addresses
    end
  end

  def valid?(ip)
    return true if ["127.0.0.1", "0.0.0.0"].include?(ip) && Rails.env == "test"
    hook_source_ips.any? { |block| IPAddr.new(block).include?(ip) }
  end

  def self.valid?(ip)
    new.valid?(ip)
  end
end
