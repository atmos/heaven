module Heaven
  module Jobs
    # An error that's raised when two deployments trigger simultaneously
    class LockedError
      @queue = :deployment_statuses

      attr_accessor :guid, :payload

      def initialize(guid, payload)
        @guid      = guid
        @payload   = payload
      end

      def self.perform(guid, payload)
        provider = Heaven::Provider::DefaultProvider.new(guid, payload)
        provider.status.description = "Already deploying."
        provider.status.error!

        Rails.logger.info "Deployment errored out, run was locked."
      end
    end
  end
end
