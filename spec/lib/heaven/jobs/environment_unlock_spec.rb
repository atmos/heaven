require "spec_helper"

describe Heaven::Jobs::EnvironmentUnlock do
  include Deployment::Status::Matchers,
          EnvironmentLocker::Matchers

  describe ".perform" do
    let(:lock_params) do
      {
        :name_with_owner => "atmos/heaven",
        :environment => "production",
        :actor => "atmos",
        :deployment_id => "12345"
      }
    end

    before do
      EnvironmentLocker.new(lock_params).lock!
    end

    it "unlocks the environment and sends a success status" do
      job = Heaven::Jobs::EnvironmentUnlock

      job.perform(lock_params)

      expect("atmos/heaven-production").to_not be_locked
      expect(Deployment::Status).to have_event("status" => "success")
    end
  end
end
