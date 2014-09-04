require "spec_helper"

describe Receiver do
  context "production environment" do
    let(:payload) { fixture_data("deployment") }
    let!(:data) { JSON.parse(payload)["payload"] }
    let!(:receiver) { Receiver.new("127.0.0.1", "deployment", "1", payload) }

    pending "needs moar tests"
  end

  context "staging environment" do
    let(:payload) { fixture_data("deployment_staging") }
    let!(:data) { JSON.parse(payload)["payload"] }
    let!(:receiver) { Receiver.new("127.0.0.1", "deployment", "1", payload) }

    pending "needs moar tests"
  end
end
