Resque.redis = Redis::Namespace.new(
  "#{Heaven::REDIS_PREFIX}:resque",
  :redis => Heaven.redis
)
