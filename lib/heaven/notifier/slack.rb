require "heaven/comparison/linked"

module Heaven
  module Notifier
    # A notifier for Slack
    class Slack < Notifier::Default
      def deliver(message)
        output_message   = ""
        filtered_message = slack_formatted(message)

        Rails.logger.info "slack: #{filtered_message}"
        Rails.logger.info "message: #{message}"

        output_message << "##{deployment_number} - #{repo_name} / #{ref} / #{environment}"
        slack_account.ping "",
          :channel     => "##{chat_room}",
          :username    => "hubot",
          :icon_url    => "https://octodex.github.com/images/labtocat.png",
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
          message << " is deploying #{repository_link("/tree/#{ref}")} to #{environment} #{compare_link}"
        else
          puts "Unhandled deployment state, #{state}"
        end
      end

      def slack_formatted(message)
        ::Slack::Notifier::LinkFormatter.format(message)
      end

      def changes
        Heaven::Comparison::Linked.new(comparison, name_with_owner).changes(COMMIT_CHANGE_LIMIT)
      end

      def compare_link
        "([compare](#{comparison["html_url"]}))" if last_known_revision
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
