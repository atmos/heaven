# A class to handle incoming lock/unlock webhooks
class LockReceiver
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def run!
    if locker.lock?
      Resque.enqueue(Heaven::Jobs::EnvironmentLock, lock_params)
    elsif locker.unlock?
      Resque.enqueue(Heaven::Jobs::EnvironmentUnlock, lock_params)
    elsif locker.locked?
      Resque.enqueue(Heaven::Jobs::EnvironmentLockedError, lock_params)
    end
  end

  private

  def locker
    @locker ||= EnvironmentLocker.new(lock_params)
  end

  def lock_params
    {}.tap do |hash|
      hash[:name_with_owner] = data["repository"]["full_name"]
      hash[:environment]     = deployment_data["environment"]
      hash[:actor]           = deployment_data["creator"]["login"]
      hash[:deployment_id]   = deployment_data["id"]
      hash[:task]            = deployment_data["task"]
    end
  end

  def deployment_data
    data["deployment"] || data
  end
end
