require "spec_helper"

describe Heaven::Provider::Capistrano do
  include FixtureHelper

  let(:deployment) { Heaven::Provider::Capistrano.new(SecureRandom.uuid, decoded_fixture_data("deployment-capistrano")) }

  it "finds deployment task" do
    expect(deployment.task).to eql "deploy:migrations"
  end
end
