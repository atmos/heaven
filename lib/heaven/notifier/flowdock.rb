module Heaven
  module Notifier
    # A notifier for flowdock
    class Flowdock < Notifier::Default
      def deliver(message)
        filtered_message = message + " #{ascii_face}"
        Rails.logger.info "flowdock: #{filtered_message}"

        params = {
          content: filtered_message,
          tags: ["Deploy"]
        }
        params[:message_id] = message_thread unless message_thread.blank?
        if use_push_api?
          flow.push_to_chat(params)
        else
          params[:flow] = chat_room
          client.chat_message(params)
        end
      end

      def flow
        @flow ||= ::Flowdock::Flow.new(api_token: flowdock_flow_api_token, external_user_name: flowdock_external_user_name)
      end

      def client
        @client ||= ::Flowdock::Client.new(api_token: flowdock_user_api_token)
      end

      def message_thread
        deployment_payload["notify"]["message_thread"]
      end

      def repository_link(path = "")
        repo_url(path)
      end

      def user_link
        "@#{chat_user}"
      end

      def output_link
        target_url
      end

      private

      def use_push_api?
        flowdock_user_api_token.blank?
      end

      def use_rest_api?
        !use_push_api?
      end

      def flowdock_flow_api_token
        ENV["FLOWDOCK_FLOW_API_TOKEN"]
      end

      def flowdock_external_user_name
        ENV["FLOWDOCK_EXTERNAL_USER_NAME"]
      end

      def flowdock_user_api_token
        ENV["FLOWDOCK_FLOW_API_TOKEN"]
      end
    end
  end
end
