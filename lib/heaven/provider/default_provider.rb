module Heaven
  # Top-level module for providers.
  module Provider
    # The super class provider, all providers inherit from this.
    class DefaultProvider
      include ApiClient
      include LocalLogFile

      attr_accessor :credentials, :guid, :last_child, :name, :payload

      # See http://stackoverflow.com/questions/12093748/how-do-i-check-for-valid-git-branch-names
      # and http://linux.die.net/man/1/git-check-ref-format
      VALID_GIT_REF = %r{\A(?!/)(?!.*(?:/\.|//|@\{|\\|\.\.))[\040-\176&&[^ ~\^:?*\[]]+(?<!\.lock|/|\.)\z}

      def initialize(guid, payload)
        @guid        = guid
        @name        = "unknown"
        @payload     = payload
        @credentials = ::Deployment::Credentials.new(working_directory)
      end

      def data
        @data ||= JSON.parse(payload)
      end

      def output
        @output ||= Deployment::Output.new(name, number, guid)
      end

      def status
        @status ||= Deployment::Status.new(name_with_owner, number)
      end

      def redis
        Heaven.redis
      end

      def log(line)
        Rails.logger.info "#{name}-#{guid}: #{line}"
      end

      def gem_executable_path(name)
        executable_path = "/app/vendor/bundle/bin/#{name}"
        if File.exist?(executable_path)
          executable_path
        else
          "bin/#{name}"
        end
      end

      def number
        data["id"]
      end

      def name
        name_with_owner
      end

      def name_with_owner
        data["repository"]["full_name"]
      end

      def sha
        deployment_data["sha"][0..7]
      end

      def ref
        deploy_ref = deployment_data["ref"]
        unless deploy_ref =~ VALID_GIT_REF
          fail "Invalid git reference #{deploy_ref.inspect}"
        end
        deploy_ref
      end

      def environment
        deployment_data["environment"]
      end

      def description
        deployment_data["description"] || "Deploying from #{Heaven::VERSION}"
      end

      def repository_url
        data["repository"]["clone_url"]
      end

      def default_branch
        data["repository"]["default_branch"]
      end

      def clone_url
        uri = Addressable::URI.parse(repository_url)
        uri.user = github_token
        uri.password = ""
        uri.to_s
      end

      def deployment_data
        data["deployment"] || data
      end

      def custom_payload
        @custom_payload ||= deployment_data["payload"]
      end

      def custom_payload_name
        custom_payload && custom_payload["name"]
      end

      def custom_payload_config
        custom_payload && custom_payload["config"]
      end

      def setup
        credentials.setup!

        output.create
        status.output = output.url
        status.pending!
      end

      def completed?
        status.completed?
      end

      def execute
        warn "Heaven Provider(#{name}) didn't implement execute"
      end

      def notify
        warn "Heaven Provider(#{name}) didn't implement notify"
      end

      def record
        Deployment.create(:custom_payload  => JSON.dump(custom_payload),
                          :environment     => environment,
                          :guid            => guid,
                          :name            => name,
                          :name_with_owner => name_with_owner,
                          :output          => output.url,
                          :ref             => ref,
                          :sha             => sha)
      end

      def timeout
        Integer(ENV["DEPLOYMENT_TIMEOUT"] || "300")
      end

      def run!
        Timeout.timeout(timeout) do
          setup
          execute unless Rails.env.test?
          notify
          record
        end
      rescue StandardError => e
        Rails.logger.info e.message
        Rails.logger.info e.backtrace
      ensure
        status.failure! unless completed?
      end
    end
  end
end
