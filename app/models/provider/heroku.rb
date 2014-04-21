module Provider
  module HerokuApiClient
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
        faraday.response :logger unless %w(staging production).include?(Rails.env)
        faraday.adapter  Faraday.default_adapter
      end
    end
  end

  class HerokuBuild
    include HerokuApiClient

    attr_accessor :id, :info, :name
    def initialize(name, id)
      @id   = id
      @name = name
      @info = info!
    end

    def info!
      response = http.get do |req|
        req.url "/apps/#{name}/builds/#{id}"
      end
      @info = JSON.parse(response.body)
    end

    def output
      response = http.get do |req|
        req.url "/apps/#{name}/builds/#{id}/result"
      end
      @output = JSON.parse(response.body)
    end

    def lines
      @lines ||= output['lines']
    end

    def stdout
      lines.map do |line|
        line['line'] if line['stream'] == "STDOUT"
      end.join
    end

    def stderr
      lines.map do |line|
        line['line'] if line['stream'] == "STDERR"
      end.join
    end

    def refresh!
      Rails.logger.info "Refreshing build #{id}"
      info!
    end

    def completed?
      success? || failed?
    end

    def success?
      info['status'] == "succeeded"
    end

    def failed?
      info['status'] == "failed"
    end
  end

  class HerokuHeavenProvider < DefaultProvider
    include HerokuApiClient

    attr_accessor :build
    def initialize(guid, payload)
      super
      @name = "heroku"
    end

    def app_name
      return nil unless custom_payload_config

      app_key = "heroku_#{environment}_name"
      if custom_payload_config.has_key?(app_key)
        custom_payload_config[app_key]
      else
        puts "Specify a There is no heroku specific app #{app_key} for the environment #{environment}"
        custom_payload_config["heroku_name"]  # default app name
      end
    end

    def archive_link
      @archive_link ||= api.archive_link(name_with_owner, :ref => sha)
    end

    def heroku_command_tweak(cmd)
      return cmd unless cmd.start_with?("heroku")
      "#{cmd} --app #{app_name}"
    end

    def execute_commands(commands)
      commands.each do |cmd|
        cmd_tweaked = heroku_command_tweak(cmd)
        Rails.logger.info "  run `#{cmd_tweaked}`"
        IO.popen(cmd_tweaked){ |out| Rails.logger.info out.read }
      end
    end

    def execute
      response = build_request
      if response.success?
        body   = JSON.parse(response.body)
        @build = HerokuBuild.new(app_name, body['id'])

        until build.completed?
          sleep 10
          build.refresh!
        end
      else
      end
    end

    def notify
      output.stderr = build.stderr
      output.stdout = build.stdout

      output.update
      if build.success?
        status.success!
      else
        status.failure!
      end
    end

    private

      def build_request
        response = http.post do |req|
          req.url "/apps/#{app_name}/builds"
          req.body = JSON.dump(:source_blob => {:url => archive_link})
        end
      end
  end
end
