module Heaven
  module Notifier
    class Default
      attr_accessor :payload

      def initialize(payload)
        @payload = JSON.parse(payload)
      end

      def deliver(message)
        fail "Unable to deliver, write your own #deliver(message) method."
      end

      def ascii_face
        case state
        when "pending"
          "•̀.̫•́✧"
        when "success"
          "(◕‿◕)"
        when "failure"
          "ಠﭛಠ"
        when "error"
          "¯_(ツ)_/¯"
        else
          "٩◔̯◔۶"
        end
      end

      def pending?
        state == "pending"
      end

      def green?
        %w(pending success).include?(state)
      end

      def state
        payload['state']
      end

      def number
        payload['id']
      end

      def target_url
        payload['target_url']
      end

      def description
        payload['description']
      end

      def deployment
        payload['deployment']
      end

      def environment
        deployment['environment']
      end

      def sha
        deployment['sha'][0..7]
      end

      def ref
        deployment['ref']
      end

      def deployment_number
        deployment['id']
      end

      def deployment_payload
        @deployment_payload ||= deployment['payload']
      end

      def chat_user
        deployment_payload['notify']['user'] || "unknown"
      end

      def chat_room
        deployment_payload['notify']['room']
      end

      def repo_name
        deployment_payload['name'] || payload['repository']['name']
      end

      def repo_url(path = "")
        payload['repository']['html_url'] + path
      end

      def repository_link(path = "")
        "[#{repo_name}](#{repo_url(path)})"
      end

      def default_message
        message = user_link
        case state
        when 'success'
          message << "'s #{environment} deployment of #{repository_link} is done! "
        when 'failure'
          message << "'s #{environment} deployment of #{repository_link} failed. "
        when 'error'
          message << "'s #{environment} deployment of #{repository_link} has errors. "
        when 'pending'
          message << " is deploying #{repository_link("/tree/#{ref}")} to #{environment}"
        else
          puts "Unhandled deployment state, #{state}"
        end
      end

      def post!
        deliver(default_message)
      end

      def user_link
        "[#{chat_user}](https://github.com/#{chat_user})"
      end

      def output_link(link_title = "deployment")
        if target_url
          "[#{link_title}](#{target_url})"
        else
          link_title
        end
      end
    end
  end
end
