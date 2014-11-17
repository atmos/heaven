require "spec_helper"

describe Heaven::Provider do
  include FixtureHelper

  describe ".from" do
    it "returns an initialized provider based on the payload config" do
      data = decoded_fixture_data("deployment")
      data["deployment"]["payload"]["config"]["provider"] = "capistrano"

      provider = Heaven::Provider.from("1", data)

      expect(provider).to be_a(Heaven::Provider::Capistrano)

      provider = Heaven::Provider.from("1", {})

      expect(provider).to be_nil
    end
  end
end
