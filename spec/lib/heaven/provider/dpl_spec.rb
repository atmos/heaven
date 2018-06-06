require "spec_helper"

describe Heaven::Provider::Dpl do
  include FixtureHelper

  context "production environment" do
    let(:data) { decoded_fixture_data("deployment") }
    let!(:deployment) { Heaven::Provider::Dpl.new(SecureRandom.uuid, data) }

    it "returns production" do
      expect(deployment.environment).to eq("production")
    end

    it "returns heroku_name" do
      expect(deployment.app_name).to eq(data["deployment"]["payload"]["config"]["heroku_name"])
    end
  end

  context "staging environment" do
    let(:data) { decoded_fixture_data("deployment_staging") }
    let!(:deployment) { Heaven::Provider::Dpl.new(SecureRandom.uuid, data) }

    it "returns staging" do
      expect(deployment.environment).to eq("staging")
    end

    it "returns heroku_staging_name" do
      expect(deployment.app_name).to eq(data["deployment"]["payload"]["config"]["heroku_staging_name"])
    end
  end
end
