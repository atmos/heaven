module Heaven
  # Top-level module for Providers.
  module Provider
    # The Amazon elastic beanstalk provider.
    class ElasticBeanstalk < DefaultProvider
      def initialize(guid, payload)
        super
        @name = "elastic_beanstalk"
      end

      def archive_name
        "#{name}-#{sha}.zip"
      end

      def archive_link
        @archive_link ||= api.archive_link(name_with_owner, :ref => sha)
      end

      def archive_zip
        archive_link.gsub(/legacy\.tar\.gz/, "deploy.zip")
      end

      def archive_path
        @archive_path ||= "#{working_directory}/#{archive_name}"
      end

      def fetch_source_code
        execute_and_log(["curl", archive_zip, "-o", archive_path])
      end

      def execute
        return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

        configure_s3_bucket
        log_stdout "Beanstalk: Fetching source code from GitHub:\n"
        fetch_source_code
        log_stdout "Beanstalk: Uploading source code: #{archive_path}\n"
        upload = upload_source_code(archive_name, archive_path)
        log_stdout "Beanstalk: Creating application: #{app_name}\n"
        app_version = create_app_version(upload.key)
        log_stdout "Beanstalk: Updating application: #{app_name}-#{environment}.\n"
        app_update  = update_app(app_version)
        status.output =  "#{base_url}?region=#{custom_aws_region}#/environment"
        status.output << "/dashboard?applicationName=#{app_name}&environmentId"
        status.output << "=#{app_update[:environment_id]}"
      end

      def base_url
        "https://console.aws.amazon.com/elasticbeanstalk/home"
      end

      def notify
        output.stderr = File.read(stderr_file).force_encoding("utf-8")
        output.stdout = File.read(stdout_file).force_encoding("utf-8")
        output.update
        status.success!
      end

      def upload_source_code(key, file)
        obj = s3.buckets[bucket_name].objects[key]
        obj.write(Pathname.new(file))
        obj
      end

      def bucket_name
        ENV["BEANSTALK_S3_BUCKET"] ||
          "heaven-elasticbeanstalk-builds-#{custom_aws_region}"
      end

      private

      def app_name
        custom_payload_config && custom_payload_config["app_name"]
      end

      def configure_s3_bucket
        return if s3.buckets.map(&:name).include?(bucket_name)
        s3.buckets.create(bucket_name)
      end

      def create_app_version(s3_key)
        options = {
          :application_name  => app_name,
          :version_label     => version_label,
          :description       => description,
          :source_bundle     => {
            :s3_key          => s3_key,
            :s3_bucket       => bucket_name
          },
          :auto_create_application => false
        }
        eb.create_application_version(options)
      end

      def update_app(version)
        options = {
          :environment_name  => environment,
          :version_label     => version[:application_version][:version_label]
        }
        eb.update_environment(options)
      end

      def version_label
        "heaven-#{sha}-#{Time.now.to_i}"
      end

      def custom_aws_region
        (custom_payload &&
         custom_payload["aws"] &&
          custom_payload["aws"]["region"]) || "us-east-1"
      end

      def aws_config
        {
          "region"            => custom_aws_region,
          "logger"            => Logger.new(stdout_file),
          "access_key_id"     => ENV["BEANSTALK_ACCESS_KEY_ID"],
          "secret_access_key" => ENV["BEANSTALK_SECRET_ACCESS_KEY"]
        }
      end

      def s3
        @s3 ||= AWS::S3.new(aws_config)
      end

      def eb
        @eb ||= AWS::ElasticBeanstalk::Client.new(aws_config)
      end
    end
  end
end
