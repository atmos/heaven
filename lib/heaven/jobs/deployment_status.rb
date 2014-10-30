module Heaven
  module Jobs
    # A deployment status handler
    class DeploymentStatus
      @queue = :deployment_statuses

      def self.perform(payload)
        notifier = Heaven::Notifier.for(payload)
        notifier.post! if notifier
      end
    end
  end
end
