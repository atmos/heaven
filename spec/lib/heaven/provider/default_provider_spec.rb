require "spec_helper"

describe Heaven::Provider::DefaultProvider do
  include FixtureHelper

  let(:valid_git_ref) { Heaven::Provider::DefaultProvider::VALID_GIT_REF }

  describe "::VALID_GIT_REF" do
    it "matches master" do
      expect("master").to match(valid_git_ref)
    end
    it "matches dev/feature" do
      expect("dev/feature").to match(valid_git_ref)
    end
    it "matches short sha"  do
      expect(SecureRandom.hex(4).first(7)).to match(valid_git_ref)
    end
    it "matches full sha" do
      expect(SecureRandom.hex(20)).to match(valid_git_ref)
    end
    it "matches branch with dashes and underscore" do
      expect("my_awesome-branch").to match(valid_git_ref)
    end
    it "matches name with single dot" do
      expect("some.feature").to match(valid_git_ref)
    end

    it "does not allow dot after slash" do
      expect("dev/.branch").not_to match(valid_git_ref)
    end
    it "does not allow space" do
      expect("dev branch").not_to match(valid_git_ref)
    end
    it "does not allow two consecutive dots" do
      expect("dev..branch").not_to match(valid_git_ref)
    end
    it "does not allow trailing /" do
      expect("branch/").not_to match(valid_git_ref)
    end
    it "does not allow trailing ." do
      expect("devbranch.").not_to match(valid_git_ref)
    end
    it "does not allow trailing .lock" do
      expect("devbranch.lock").not_to match(valid_git_ref)
    end
    it "does not allow @{" do
      expect("dev@{branch").not_to match(valid_git_ref)
    end
    it "does not allow \\" do
      expect("dev\\\\branch").not_to match(valid_git_ref)
    end
  end

  context "production environment" do
    let(:data) { decoded_fixture_data("deployment") }
    let!(:deployment) { Heaven::Provider::DefaultProvider.new(SecureRandom.uuid, data) }

    it "returns production" do
      expect(deployment.environment).to eq("production")
    end

    it "returns environment_url" do
      expect(deployment.environment_url).to eq(
        data["deployment"]["payload"]["config"]["production_url"]
      )
    end
  end

  context "staging environment" do
    let(:data) { decoded_fixture_data("deployment_staging") }
    let!(:deployment) { Heaven::Provider::DefaultProvider.new(SecureRandom.uuid, data) }

    it "returns staging" do
      expect(deployment.environment).to eq("staging")
    end

    it "returns environment_url" do
      expect(deployment.environment_url).to eq(
        data["deployment"]["payload"]["config"]["staging_url"]
      )
    end
  end
end
