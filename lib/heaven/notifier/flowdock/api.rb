module Heaven
  module Notifier
    # Flowdock Api interactions
    module FlowdockApi
      def thread_client
        @thread_client ||= Faraday.new ::Flowdock::FLOWDOCK_API_URL do |connection|
          connection.request :json
          connection.response :json, :content_type => /\bjson$/
          connection.use Faraday::Response::RaiseError
          connection.use Faraday::Response::Logger, Rails.logger if Rails.logger.debug?
          connection.adapter Faraday.default_adapter
        end
      end

      def auth_client
        @auth_client ||= ::Flowdock::Client.new(:api_token => flowdock_user_api_token)
      end

      def flowdock_user_api_token
        ENV["FLOWDOCK_USER_API_TOKEN"]
      end

      def flow_token
        JSON.parse(ENV["FLOWDOCK_FLOW_TOKENS"])[chat_room]
      rescue JSON::ParserError => e
        Rails.logger.error "Failed parsing FLOWDOCK_FLOW_TOKENS: #{e}"
        nil
      end
    end
  end
end
