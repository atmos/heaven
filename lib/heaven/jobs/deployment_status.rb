module Heaven
  module Jobs
    class DeploymentStatus
      @queue = :deployment_statuses

      attr_accessor :guid, :payload

      def initialize(guid, payload)
        @guid      = guid
        @payload   = payload
      end

      def self.perform(guid, payload)
        notifier = Heaven::Notifier.for(payload)
        notifier.post! if notifier
      end
    end
  end
end
