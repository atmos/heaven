module Provider
  class ElasticBeanstalk < DefaultProvider
    def initialize(guid, payload)
      super
      @name = "elastic_beanstalk"
    end

    def task
      custom_payload && custom_payload['task'] || 'deploy'
    end

    def archive_name
      "#{name}-#{sha}.zip"
    end

    def fetch_source_code
    end

    def execute
      return execute_and_log(["/usr/bin/true"]) if Rails.env.test?

      configure_s3_bucket
      log "Beanstalk: Fetching source code:"
      filename = fetch_source_code
      log "Beanstalk: Uploading source code:"
      upload = upload_source_code(archive_name, filename)
      log "Beanstalk: Creating application:"
      app_version = create_app_version(upload.key)
      log "Beanstalk: Updating application:"
      update_app(app_version)

      log "Done executing elastic beanstalk:"
    end

    def notify
      output.stderr = File.read(stderr_file)
      output.stdout = File.read(stdout_file)
      output.update
      if last_child.success?
        status.success!
      else
        status.failure!
      end
    end

    def upload_source_code(key, file)
      obj = s3.buckets[bucket_name].objects[key]
      obj.write(Pathname.new(file))
      obj
    end

    def bucket_name
      ENV["HEAVEN_S3_BEANSTALK_BUCKET"] || 
        "heaven-elasticbeanstalk-builds-#{region}"
    end

    private

      def configure_s3_bucket
        unless s3.buckets.map(&:name).include?(bucket_name)
          s3.buckets.create(bucket_name)
        end
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

      def version_label
        "heaven-#{sha}-#{Time.now.to_i}"
      end

      def custom_aws_region
        custom_payload &&
         custom_payload['aws'] &&
          custom_payload['aws']['region']
      end

      def aws_config
        {
          region:            custom_aws_region || 'us-east-1',
          access_key_id:     ENV['BEANSTALK_ACCESS_KEY_ID'],
          secret_access_key: ENV['BEANSTALK_ACCESS_SECRET_KEY_ID']
        }
      end

      def s3
        @s3 ||= AWS::S3.new(aws_config)
      end

      def eb
        @eb ||= AWS::ElasticBeanstalk.new.client(aws_config)
      end
  end
end
