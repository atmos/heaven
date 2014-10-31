require "heaven/comparison/default"

module Heaven
  module Notifier
    # The class that all notifiers inherit from
    class Default
      COMMIT_CHANGE_LIMIT = ENV["COMMIT_CHANGE_LIMIT"] ? ENV["COMMIT_CHANGE_LIMIT"].to_i : nil

      include ApiClient

      attr_accessor :payload
      attr_writer :comparison

      def initialize(payload)
        @payload = JSON.parse(payload)
      end

      def deliver(message)
        fail "Unable to deliver, write your own #deliver(#{message}) method."
      end

      def ascii_face
        case state
        when "pending" then "•̀.̫•́✧"
        when "success" then "(◕‿◕)"
        when "failure" then "ಠﭛಠ"
        when "error"   then "¯_(ツ)_/¯"
        else
          "٩◔̯◔۶"
        end
      end

      def pending?
        state == "pending"
      end

      def success?
        state == "success"
      end

      def deploy?
        task == "deploy"
      end

      def change_delivery_enabled?
        ENV["DELIVER_CHANGES"]
      end

      def green?
        %w{pending success}.include?(state)
      end

      def deployment_status_data
        payload["deployment_status"] || payload
      end

      def state
        deployment_status_data["state"]
      end

      def number
        deployment_status_data["id"]
      end

      def target_url
        deployment_status_data["target_url"]
      end

      def description
        deployment_status_data["description"]
      end

      def deployment
        payload["deployment"]
      end

      def environment
        deployment["environment"]
      end

      def task
        deployment["task"]
      end

      def sha
        deployment["sha"][0..7]
      end

      def ref
        deployment["ref"]
      end

      def deployment_number
        deployment["id"]
      end

      def deployment_payload
        @deployment_payload ||= deployment["payload"]
      end

      def chat_user
        deployment_payload["notify"]["user"] || "unknown"
      end

      def chat_room
        deployment_payload["notify"]["room"]
      end

      def repo_name
        deployment_payload["name"] || payload["repository"]["name"]
      end

      def name_with_owner
        payload["repository"]["full_name"]
      end

      def repo_url(path = "")
        payload["repository"]["html_url"] + path
      end

      def repository_link(path = "")
        "[#{repo_name}](#{repo_url(path)})"
      end

      def default_message
        message = user_link
        case state
        when "success"
          message << "'s #{environment} deployment of #{repository_link} is done! "
        when "failure"
          message << "'s #{environment} deployment of #{repository_link} failed. "
        when "error"
          message << "'s #{environment} deployment of #{repository_link} has errors. "
        when "pending"
          message << " is deploying #{repository_link("/tree/#{ref}")} to #{environment}"
        else
          puts "Unhandled deployment state, #{state}"
        end
      end

      def changes
        Heaven::Comparison::Default.new(comparison).changes(COMMIT_CHANGE_LIMIT)
      end

      def comparison
        @comparison ||= api.compare(name_with_owner, last_known_revision, sha).as_json
      end

      def last_known_revision
        Heaven.redis.get("#{name_with_owner}-production-revision")
      end

      def record_revision
        Heaven.redis.set("#{name_with_owner}-#{environment}-revision", sha)
      end

      def post!
        deliver(default_message)

        return unless success? && deploy?

        deliver(changes) if deliver_changes?

        record_revision
      end

      def deliver_changes?
        change_delivery_enabled? && last_known_revision.present?
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
