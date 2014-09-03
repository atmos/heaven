module Heaven
  module Jobs
    class Deployment
      extend Resque::Plugins::LockTimeout

      @queue = :deployments
      @lock_timeout = Integer(ENV['DEPLOYMENT_TIMEOUT'] || '300')

      # Only allow one deployment per-environment at a time
      def self.redis_lock_key(guid, payload)
        data = JSON.parse(payload)
        if payload = data['payload']
          if name = payload['name']
            return "#{name}-#{data['environment']}"
          end
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
        provider = ::Provider.from(guid, payload)
        provider.run! if provider
      end
    end
  end
end
