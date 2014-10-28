module Heaven
  REDIS_PREFIX = "heaven:#{Rails.env}"

  class << self
    attr_writer :testing, :redis

    def testing?
      @testing.present?
    end

    def redis
      @redis ||= if ENV['REDIS_PROVIDER']
                   Redis.new(:url => ENV[ENV['REDIS_PROVIDER']])
                 elsif ENV["REDISCLOUD_URL"]
                   Redis.new(:url => ENV['REDISCLOUD_URL'])
                 elsif ENV["OPENREDIS_URL"]
                   Redis.new(:url => ENV['OPENREDIS_URL'])
                 elsif ENV["BOXEN_REDIS_URL"]
                   Redis.new(:url => ENV['BOXEN_REDIS_URL'])
                 else
                   Redis.new
                 end

      Resque.redis = Redis::Namespace.new("#{REDIS_PREFIX}:resque", :redis => @redis)
      @redis
    end

    def redis_reconnect!
      @redis = nil
      redis
    end
  end
end

# initialize early to ensure proper resque prefixes
Heaven.redis
