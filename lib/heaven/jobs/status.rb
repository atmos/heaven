module Heaven
  module Jobs
    class Status
      @queue = :statuses

      attr_accessor :guid, :payload

      def initialize(guid, payload)
        @guid      = guid
        @payload   = payload
      end

      def self.perform(guid, payload)
        CommitStatus.new(guid, payload).run!
      end
    end
  end
end
