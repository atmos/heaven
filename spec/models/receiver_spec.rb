require "spec_helper"

describe Receiver do
  describe "#dpl_arguments" do
    subject { Receiver.new("event", "guid", "payload") }

    it "generates a list of arguments from the env" do
      env = { "DPL_PROVIDER" => "heroku",
              "DPL_API_KEY"  => "an_api_key",
              "DPL_USERNAME" => "a_user",
              "DPL_PASSWORD" => "a_password",
              "DPL_APP"      => "an_app",
              "DPL_STRATEGY" => "anvil" }

      expect(subject.dpl_arguments(env)).to include(
        "--provider=heroku", "--api-key=an_api_key", "--username=a_user",
        "--password=a_password", "--app=an_app", "--strategy=anvil"
      )
    end

    it "allows for default values" do
      env = { "DPL_PROVIDER" => "heroku",
              "DPL_API_KEY"  => "an_api_key",
              "DPL_USERNAME" => "a_user",
              "DPL_PASSWORD" => "a_password",
              "DPL_APP"      => "an_app" }

      expect(subject.dpl_arguments(env)).to include("--strategy=git")
    end

    it "fails if required values are not present" do
      env = { "DPL_PROVIDER" => "heroku" }
      expect { subject.dpl_arguments(env) }.to raise_error
    end
  end
end
