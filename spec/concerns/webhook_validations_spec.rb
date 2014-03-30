require "spec_helper"

describe WebhookValidations do
  class WebhookValidationsTester
    class Request
      def initialize(ip)
        @ip = ip
      end
      attr_accessor :ip
    end
    include WebhookValidations

    def initialize(ip)
      @ip = ip
    end

    def request
      Request.new(@ip)
    end
  end

  it "makes methods available" do
    klass = WebhookValidationsTester.new("192.30.252.41")
    expect(klass).to be_valid_incoming_webhook_address
    klass = WebhookValidationsTester.new("127.0.0.1")
    expect(klass).to_not be_valid_incoming_webhook_address
  end

  context "verifies IPs" do
    it "returns production" do
      expect(WebhookValidations::Validator.new("127.0.0.1")).to_not be_valid
      expect(WebhookValidations::Validator.new("192.30.252.41")).to be_valid
      expect(WebhookValidations::Validator.new("192.30.252.46")).to be_valid
    end
  end
end
