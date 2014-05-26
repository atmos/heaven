module Heaven
  module Notifier
    class Slack < Notifier::Default
      def deliver(message)
        output_message   = ::Slack::Notifier::LinkFormatter.format(output_link('Logs'))
        filtered_message = ::Slack::Notifier::LinkFormatter.format(message + " #{ascii_face}")

        Rails.logger.info "slack: #{filtered_message}"

        slack_account.ping "",
          :channel     => "##{chat_room}",
          :username    => "Deployment ##{deployment_number} - #{repo_name} / #{ref} / #{environment}",
          :icon_url    => "https://octodex.github.com/images/labtocat.png",
          :attachments => [{
            :text    => filtered_message,
            :color   => green? ? "good" : "danger",
            :pretext => pending? ? output_message : " "
          }]
      end

      def slack_token
        ENV['SLACK_TOKEN']
      end

      def slack_subdomain
        ENV['SLACK_SUBDOMAIN'] || 'unknown'
      end

      def slack_account
        @slack_account ||= ::Slack::Notifier.new(slack_subdomain, slack_token)
      end
    end
  end
end
