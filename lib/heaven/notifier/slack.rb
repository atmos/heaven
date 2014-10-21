module Heaven
  module Notifier
    # A notifier for Slack
    class Slack < Notifier::Default
      def deliver(message)
        output_message   = ""
        filtered_message = ::Slack::Notifier::LinkFormatter.format(message)

        Rails.logger.info "slack: #{filtered_message}"
        Rails.logger.info "message: #{message}"

        output_message << "##{deployment_number} - #{repo_name} / #{ref} / #{environment}"
        slack_account.ping "",
          :channel     => "##{chat_room}",
          :username    => "Capybot",
          :icon_url    => "https://s3-us-west-2.amazonaws.com/slack-files2/bot_icons/2014-06-17/2399828904_48.png",
          :attachments => [{
            :text    => filtered_message,
            :color   => green? ? "good" : "danger",
            :pretext => pending? ? output_message : " "
          }]
      end

      def default_message
        message = output_link("##{deployment_number}")
        message << " : #{user_link}"
        case state
        when "success"
          message << "'s #{environment} deployment of #{repository_link} is done! "
        when "failure"
          message << "'s #{environment} deployment of #{repository_link} failed. "
        when "error"
          message << "'s #{environment} deployment of #{repository_link} has errors. #{ascii_face} "
          message << description unless description =~ /Deploying from Heaven/
        when "pending"
          message << " is deploying #{repository_link("/tree/#{ref}")} to #{environment}"
        else
          puts "Unhandled deployment state, #{state}"
        end
      end

      def slack_token
        ENV["SLACK_TOKEN"]
      end

      def slack_subdomain
        ENV["SLACK_SUBDOMAIN"] || "unknown"
      end

      def slack_account
        @slack_account ||= ::Slack::Notifier.new(slack_subdomain, slack_token)
      end
    end
  end
end
