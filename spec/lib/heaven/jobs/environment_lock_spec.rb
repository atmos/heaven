require "spec_helper"

describe Heaven::Jobs::EnvironmentLock do
  include Deployment::Status::Matchers, EnvironmentLocker::Matchers

  describe ".perform" do
    let(:lock_params) do
      {
        :name_with_owner => "atmos/heaven",
        :environment => "production",
        :actor => "atmos",
        :deployment_id => "12345"
      }
    end

    it "locks the environment and sends a success status" do
      job = Heaven::Jobs::EnvironmentLock

      job.perform(lock_params)

      expect("atmos/heaven-production").to be_locked
      expect(Deployment::Status).to have_event("status" => "success")
    end
  end
end
