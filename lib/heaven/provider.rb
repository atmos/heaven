require "heaven/provider/default_provider"
require "heaven/provider/capistrano"
require "heaven/provider/heroku"
require "heaven/provider/fabric"
require "heaven/provider/elastic_beanstalk"
require "heaven/provider/dpl"
require "heaven/provider/bundler_capistrano"

# The top-level Heaven module
module Heaven
  # A dispatcher for provider identification
  module Provider
    def self.from(guid, payload)
      klass = provider_class_for(payload)
      klass.new(guid, payload) if klass
    end

    def self.provider_class_for(payload)
      case provider_name_for(payload)
      when "heroku"
        Provider::HerokuHeavenProvider
      when "capistrano"
        Provider::Capistrano
      when "fabric"
        Provider::Fabric
      when "elastic_beanstalk"
        Provider::ElasticBeanstalk
      when "bundler_capistrano"
        Provider::BundlerCapistrano
      else
        Rails.logger.info "No deployment system for #{provider_name_for(payload)}"
      end
    end

    def self.provider_name_for(payload)
      data = JSON.parse(payload)
      if data && data["deployment"]["payload"]
        if data["deployment"]["payload"]["config"]
          return data["deployment"]["payload"]["config"]["provider"]
        end
      end
    end
  end
end
