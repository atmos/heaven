module Heaven
  module Notifier
    # A notifier for Hipchat
    class Hipchat < Notifier::Default
      def deliver(message)
        filtered_message = message + " #{ascii_face}"
        Rails.logger.info "hipchat: #{filtered_message}"

        hipchat_client["#{hipchat_room}"].send "hubot", filtered_message,
          :color => green? ? "green" : "red",
          :notify => 1,
          :message_format => "text"
      end

      def hipchat_token
        ENV["HIPCHAT_TOKEN"]
      end

      def hipchat_room
        ENV["HIPCHAT_ROOM"] || "Developers"
      end

      def hipchat_server
        ENV["HIPCHAT_SERVER"] || "https://api.hipchat.com"
      end

      def hipchat_client
        @hipchat_client ||= ::HipChat::Client.new(hipchat_token, :server_url => hipchat_server)
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
    end
  end
end
