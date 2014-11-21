module Heaven
  module Jobs
    # A job for unlocking the environment
    class EnvironmentLock
      @queue = :locks

      def self.perform(lock_params)
        lock_params.symbolize_keys!
        locker = EnvironmentLocker.new(lock_params)
        locker.lock!

        status = ::Deployment::Status.new(lock_params[:name_with_owner], lock_params[:deployment_id])
        status.description = "#{locker.name_with_owner} locked on #{locker.environment} by #{locker.actor}"

        status.success!
      end
    end
  end
end
