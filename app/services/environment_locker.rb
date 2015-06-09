# A class for lock/unlocking a repo's environment
class EnvironmentLocker
  LOCK_TASK     = "lock".freeze
  UNLOCK_TASK   = "unlock".freeze
  UNKNOWN_ACTOR = "Unknown".freeze

  attr_reader :name_with_owner, :environment, :actor, :task
  attr_writer :redis

  def initialize(lock_params)
    @name_with_owner = lock_params.fetch(:name_with_owner)
    @environment     = lock_params.fetch(:environment)
    @actor           = lock_params[:actor]
    @task            = lock_params[:task]
  end

  def lock?
    task == "#{prefix}:#{LOCK_TASK}"
  end

  def unlock?
    task == "#{prefix}:#{UNLOCK_TASK}"
  end

  def lock!
    redis.set(redis_key, actor)
  end

  def unlock!
    redis.del(redis_key)
  end

  def locked?
    redis.exists(redis_key)
  end

  def locked_by
    redis.get(redis_key) || UNKNOWN_ACTOR
  end

  private

  def redis
    @redis ||= Heaven.redis
  end

  def redis_key
    [name_with_owner, environment, "lock"].join("-")
  end

  def prefix
    ENV["HUBOT_DEPLOY_PREFIX"] || "deploy"
  end
end
