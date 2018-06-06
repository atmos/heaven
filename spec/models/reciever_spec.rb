require "spec_helper"

describe Receiver do
  include FixtureHelper

  describe "#run!" do
    before { stub_gists }

    it "triggers a deployment for deployment events" do
      data     = decoded_fixture_data("deployment")
      receiver = Receiver.new("deployment", "1", data)

      expect(Resque).to receive(:enqueue).with(Heaven::Jobs::Deployment, "1", data)

      receiver.run!
    end

    it "triggers a deployment status for deployment status events" do
      data     = decoded_fixture_data("deployment-pending")
      receiver = Receiver.new("deployment_status", "1", data)

      expect(Resque).to receive(:enqueue).with(Heaven::Jobs::DeploymentStatus, data)

      receiver.run!
    end

    it "triggers a status for status events" do
      data     = decoded_fixture_data("status_success")
      receiver = Receiver.new("status", "1", data)

      expect(Resque).to receive(:enqueue).with(Heaven::Jobs::Status, "1", data)

      receiver.run!
    end
  end

  describe "#active_repository?" do
    let(:data)     { decoded_fixture_data("deployment") }
    let(:receiver) { Receiver.new("deployment", "1", data) }

    it "is true if the repository is active" do
      Repository.create(:name => "my-robot", :owner => "atmos", :active => true)

      expect(receiver).to be_active_repository
    end

    it "is false if the repository is inactive" do
      Repository.create(:name => "my-robot", :owner => "atmos", :active => false)

      expect(receiver).to_not be_active_repository
    end

    it "is false if a repository is missing from the payload" do
      receiver.data.delete("repository")

      expect(receiver).to_not be_active_repository
    end
  end
end
