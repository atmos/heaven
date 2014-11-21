module Heaven
  module Notifier
    # Helpers for generating flowdock messages
    module FlowdockMessageHelper
      def tags
        ["deploy", environment, repo_name, state].compact
      end

      def build_status_avatar
        if %(success pending).include?(state)
          "https://d2ph5hv9wbwvla.cloudfront.net/heaven/build_ok.png"
        else
          "https://d2ph5hv9wbwvla.cloudfront.net/heaven/build_fail.png"
        end
      end

      def thread_status_color
        case state
        when "success"
          "green"
        when "error", "failure"
          "red"
        when "pending"
          "yellow"
        else
          nil
        end
      end

      def activity_title
        case state
        when "success"
          "#{repo_name} deployed with ref #{ref} to #{environment}."
        when "error"
          "Error deploying #{repo_name} to #{environment}."
        when "failure"
          "Failed deploying #{repo_name} to #{environment}."
        when "pending"
          "Started deploying #{repo_name} to #{environment}."
        else
          puts "Unhandled deployment state, #{state}"
        end
      end
    end
  end
end
