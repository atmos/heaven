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
    else
      Rails.logger.info "No deployment system for #{provider_name_for(payload)}"
    end
  end

  def self.provider_name_for(payload)
    data = JSON.parse(payload)
    if data && data['payload']
     if custom_payload = data['payload']['config']
       return custom_payload['provider']
     end
    end
  end
end
