module Heaven
  module Jobs
    # A deployment status handler
    class DeploymentStatus
      @queue = :deployment_statuses

      def self.perform(payload)
        data = JSON.parse(payload)

        sha             = data["deployment"]["sha"]
        name_with_owner = data["repository"]["full_name"]
        environment     = data["deployment"]["environment"]
        state           = data["deployment_status"]["state"]

        deployment = ::Deployment.where(
          :sha => sha,
          :name_with_owner => name_with_owner,
          :environment => environment
        ).last

        deployment.update_attribute(:state, state) if deployment

        notifier = Heaven::Notifier.for(payload)
        notifier.post! if notifier
      end
    end
  end
end
