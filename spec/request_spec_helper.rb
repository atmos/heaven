require "spec_helper"

module ApiHelper
  def send_and_accept_json
    header "Accept", "application/json"
    header "Content-Type", "application/json"
  end

  def request_env(remote_ip = "192.30.252.41")
    { "REMOTE_ADDR" => remote_ip,
      "X_FORWARDED_FOR" => remote_ip }
  end

  def github_event(event)
    header "X-Github-Event", event
    header "X-Github-Delivery", SecureRandom.uuid
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include ApiHelper
  config.include MetaHelper

  config.before :type => :request do
    send_and_accept_json
    stub_meta
  end
end
