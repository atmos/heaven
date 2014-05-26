module Heaven
  module Jobs
    class Deployment
      extend Resque::Plugins::Lock

      @queue = :deployments

      # Only allow one deployment per-environment at a time
      def self.lock(guid, payload)
        data = JSON.parse(payload)
        if payload = data['payload']
          if name = payload['name']
            return "#{name}-#{data['environment']}"
          end
        end
        guid
      end

      attr_accessor :guid, :payload

      def initialize(guid, payload)
        @guid      = guid
        @payload   = payload
      end

      def self.perform(guid, payload)
        provider = ::Provider.from(guid, payload)
        provider.run!
      end
    end
  end
end
