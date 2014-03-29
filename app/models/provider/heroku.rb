module Provider
  class Heroku < DefaultProvider
    def initialize(guid, payload, token)
      super
      @name = "heroku"
    end

    def build
      @build ||= post_build
    end

    def build_id
      build["id"]
    end

    def app_name
      return nil unless custom_payload_config
      environment == "staging" ?
        custom_payload_config['heroku_staging_name'] :
        custom_payload_config['heroku_name']
    end

    def archive_link
      @archive_link ||= api.archive_link(name_with_owner, :ref => sha)
    end

    def execute
      Rails.logger.info "Build heroku #{build_id}"
    end

    def notify
      successful = true
      output.update("", "")
      if successful
        status.success!
      else
        status.failure!
      end
    end

    private
      def http_options
        {
          :url     => "https://api.heroku.com",
          :headers => {
            "Accept"        => "application/vnd.heroku+json; version=3",
            "Content-Type"  => "application/json",
            "Authorization" => Base64.encode64(":#{ENV['HEROKU_API_KEY']}")
          }
        }
      end

      def http
        @http ||= Faraday.new(http_options) do |faraday|
          faraday.request  :url_encoded
          faraday.response :logger
          faraday.adapter  Faraday.default_adapter
        end
      end

      def post_build
        response = http.post do |req|
          req.url "/apps/#{app_name}/builds"
          req.body = JSON.dump(:source_blob => {:url => archive_link})
        end
        JSON.parse(response.body)
      end
  end
end
