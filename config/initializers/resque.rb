module Heaven
  REDIS_PREFIX = "heroku-deploy:#{Rails.env}"

  def self.redis
    @redis ||= if ENV["OPENREDIS_URL"]
                 uri = URI.parse(ENV["OPENREDIS_URL"])
                 Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
               elsif ENV["BOXEN_REDIS_URL"]
                 uri = URI.parse(ENV["BOXEN_REDIS_URL"])
                 Redis.new(:host => uri.host, :port => uri.port)
               else
                 Redis.new
               end
    Resque.redis = Redis::Namespace.new("#{REDIS_PREFIX}:resque", :redis => @redis)
    @redis
  end

  def self.redis_reconnect!
    @redis = nil
    redis
  end
end

# initialize early to ensure proper resque prefixes
Heaven.redis
