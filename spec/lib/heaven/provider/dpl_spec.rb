require "spec_helper"

describe Heaven::Provider::Dpl do
  context "production environment" do
    let(:payload) { fixture_data("deployment") }
    let!(:data) { JSON.parse(payload)["payload"] }
    let!(:deployment) { Heaven::Provider::Dpl.new(SecureRandom.uuid, payload) }

    it "returns production" do
      expect(deployment.environment).to eq("production")
    end

    it "returns heroku_name" do
      expect(deployment.app_name).to eq(data["config"]["heroku_name"])
    end
  end

  context "staging environment" do
    let(:payload) { fixture_data("deployment_staging") }
    let!(:data) { JSON.parse(payload)["payload"] }
    let!(:deployment) { Heaven::Provider::Dpl.new(SecureRandom.uuid, payload) }

    it "returns staging" do
      expect(deployment.environment).to eq("staging")
    end

    it "returns heroku_staging_name" do
      expect(deployment.app_name).to eq(data["config"]["heroku_staging_name"])
    end
  end
end
