module Heaven
  module Jobs
    class Deployment
      @queue = :deployments

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
