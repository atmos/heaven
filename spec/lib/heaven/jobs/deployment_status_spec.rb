require "spec_helper"

describe Heaven::Jobs::DeploymentStatus do
  let(:payload)    { fixture_data("deployment-success") }
  let(:data)       { JSON.parse(payload) }
  let!(:deployment) do
    Deployment.create(
      :sha => data["sha"],
      :name => data["repository"]["name"],
      :name_with_owner => data["repository"]["full_name"],
      :sha => data["deployment"]["sha"],
      :state => "pending"
    )
  end

  describe ".perform" do
    it "records the state for the matching deployment" do
      job = Heaven::Jobs::DeploymentStatus

      job.perform(payload)

      expect(deployment.reload.state).to eq("success")
    end
  end
end
