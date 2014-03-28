module Provider
  def self.from(guid, payload, token)
    klass = provider_class_from(payload)
    klass.new(guid, payload, token)
  end

  def self.provider_class_for(payload)
    case provider_name_for(payload)
    when "heroku"
      Provider::Heroku
    else
      Provider::Dpl
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
