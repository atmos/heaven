module Heaven
  module Notifier
    # A notifier for flowdock
    class Flowdock < Notifier::Default

      def deliver(message)
        Rails.logger.info "flowdock: #{message}"
        if flow_token.nil?
          Rails.logger.error "Could not find flow token for flow #{chat_room}"
          return
        end
        response = thread_client.post '/messages', {
          flow_token: flow_token,
          event: 'activity',
          external_id: flowdock_thread_id,
          thread: thread_data,
          title: activity_title,
          author: activity_author,
        }
        if state == 'pending' && !autodeploy?
          answer_to_chat(response.body['thread_id'])
        end
      end

      def answer_to_chat(deployment_thread_id)
        flow = auth_client.get('/flows/find', {id: chat_room})
        params = {
          content: "Deployment started: #{thread_url(flow, deployment_thread_id)}"
        }
        if !thread_id.blank?
          params[:thread_id] = thread_id
        elsif !message_id.blank?
          params[:message_id] = message_id
        end
        params[:flow] = chat_room
        auth_client.chat_message(params)
      end

      def thread_id
        deployment_payload["notify"]["thread_id"]
      end

      def message_id
        deployment_payload["notify"]["message_id"]
      end

      def output_link
        target_url
      end

      def tags
        ['deploy', environment, repo_name, state].compact
      end

      def push_api_content
        "<p>#{deployment['description']}</p>"
      end

      def thread_client
        @thread_client ||= Faraday.new ::Flowdock::FLOWDOCK_API_URL do |connection|
          connection.request :json
          connection.response :json, content_type: /\bjson$/
          connection.use Faraday::Response::RaiseError
          connection.use Faraday::Response::Logger, Rails.logger if Rails.logger.debug?
          connection.adapter Faraday.default_adapter
        end
      end

      def auth_client
        @auth_client ||= ::Flowdock::Client.new(api_token: flowdock_user_api_token)
      end

      def flowdock_user_api_token
        ENV["FLOWDOCK_USER_API_TOKEN"]
      end

      def flow_token
        JSON.parse(ENV["FLOWDOCK_FLOW_TOKENS"])[chat_room]
      rescue JSON::ParseError => e
        Rails.logger.error 'Failed parsing FLOWDOCK_FLOW_TOKENS'
        nil
      end

      def thread_data
        {
          title: "Deployment ##{deployment_number} of #{repo_name} to #{environment}",
          body: "<p>#{deployment['description']}</p>",
          external_url: target_url,
          status: {
            value: state,
            color: thread_status_color
          },
          fields: [
            {label: "Deployment", value: deployment_number},
            {label: "Application", value: repo_name},
            {label: "Repository", value: "<a href='#{repo_url}'>#{payload['repository']['full_name']}</a>"},
            {label: "Environment", value: environment},
            {label: "Branch", value: "<a href='#{repo_url("/tree/#{ref}")}'>#{ref}</a>"},
            {label: "Sha", value: "<a href='#{repo_url("/commits/#{deployment['sha']}")}'>#{sha}</a>"}
          ]
        }
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

      def activity_author
        {
          name: ENV['FLOWDOCK_USER_NAME'] || 'Heaven',
          avatar: ENV['FLOWDOCK_USER_AVATAR'],
          email: ENV['FLOWDOCK_USER_EMAIL'] || build_status_email
        }
      end

      private

      def repo_default_branch
        payload["repository"]["default_branch"]
      end

      def autodeploy?
        deployment["description"].start_with?("Auto-Deployed")
      end

      def flowdock_thread_id
        "heaven:deployment:#{payload['repository']['full_name'].gsub('/', ':')}:#{deployment_number}"
      end

      def thread_url(flow, id)
        "#{flow['web_url']}/threads/#{id}"
      end

      def build_status_email
        if %(success pending).include?(state)
          'build+ok@flowdock.com'
        else
          'build+fail@flowdock.com'
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
    end
  end
end
