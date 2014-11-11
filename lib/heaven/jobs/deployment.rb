module Heaven
  module Jobs
    # A class for kicking off deployment processes
    class Deployment
      extend Resque::Plugins::LockTimeout

      @queue = :deployments
      @lock_timeout = Integer(ENV["DEPLOYMENT_TIMEOUT"] || "300")

      # Only allow one deployment per-environment at a time
      def self.redis_lock_key(guid, payload)
        data = JSON.parse(payload)
        if data["payload"] && data["payload"]["name"]
          name = data["payload"]["name"]
          return "#{name}-#{data["environment"]}-deployment"
        end
        guid
      end

      def self.identifier(guid, payload)
        redis_lock_key(guid, payload)
      end

      attr_accessor :guid, :payload

      def initialize(guid, payload)
        @guid      = guid
        @payload   = payload
      end

      def self.perform(guid, payload)
        provider = Heaven::Provider.from(guid, payload)
        provider.run! if provider
      end
    end
  end
end
