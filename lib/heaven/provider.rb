require "heaven/provider/default_provider"
require "heaven/provider/capistrano"
require "heaven/provider/heroku"
require "heaven/provider/fabric"
require "heaven/provider/elastic_beanstalk"
require "heaven/provider/dpl"
require "heaven/provider/bundler_capistrano"
require "heaven/provider/ansible"

# The top-level Heaven module
module Heaven
  # A dispatcher for provider identification
  module Provider
    PROVIDERS ||= {
      "heroku"             => HerokuHeavenProvider,
      "capistrano"         => Capistrano,
      "fabric"             => Fabric,
      "elastic_beanstalk"  => ElasticBeanstalk,
      "bundler_capistrano" => BundlerCapistrano,
      "ansible"            => Ansible
    }

    def self.from(guid, data)
      klass = provider_class_for(data)
      klass.new(guid, data) if klass
    end

    def self.provider_class_for(data)
      name     = provider_name_for(data)
      provider = PROVIDERS[name]

      Rails.logger.info "No deployment system for #{name}" unless provider

      provider
    end

    def self.provider_name_for(data)
      return unless data &&
                    data.key?("deployment") &&
                    data["deployment"].key?("payload") &&
                    data["deployment"]["payload"].key?("config")

      data["deployment"]["payload"]["config"]["provider"]
    end
  end
end
