module Heaven
  module Jobs
    # A class for kicking off deployment processes
    class Deployment
      extend Resque::Plugins::LockTimeout

      @queue = :deployments
      @lock_timeout = Integer(ENV["DEPLOYMENT_TIMEOUT"] || "300")

      # Only allow one deployment per-environment at a time
      def self.redis_lock_key(guid, data)
        if data["payload"] && data["payload"]["name"]
          name = data["payload"]["name"]
          return "#{name}-#{data["environment"]}-deployment"
        end
        guid
      end

      def self.identifier(guid, data)
        redis_lock_key(guid, data)
      end

      attr_accessor :guid, :data

      def initialize(guid, data)
        @guid = guid
        @data = data
      end

      def self.perform(guid, data)
        provider = Heaven::Provider.from(guid, data)
        provider.run! if provider
      end
    end
  end
end
