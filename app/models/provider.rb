module Provider
  def self.from_payload(guid, payload, token)
    Provider::Dpl.new(guid, payload, token)
  end
end
