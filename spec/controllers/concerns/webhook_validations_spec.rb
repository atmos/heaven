require "spec_helper"

describe WebhookValidations do
  include MetaHelper

  before { stub_meta }

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
end
