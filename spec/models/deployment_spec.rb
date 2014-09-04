require "spec_helper"

describe Deployment do
  let(:payload) { fixture_data("deployment") }
  let!(:data) { JSON.parse(payload)["payload"] }

  let!(:create_data) do
    {
      :custom_payload  => JSON.dump(data),
      :environment     => "production",
      :guid            => SecureRandom.uuid,
      :name            => "hubot",
      :name_with_owner => "github/hubot",
      :output          => "https://gist.github.com/1",
      :ref             => "master",
      :sha             => "f24b8008"
    }
  end

  it "works with dynamic finders" do
    deployment = Deployment.create create_data
    expect(deployment).to be_valid
  end

  it "#latest_for_name_with_owner" do
    present = []
    Deployment.create create_data
    present << Deployment.create(create_data)

    Deployment.create create_data.merge(:name => "mybot")
    present << Deployment.create(create_data.merge(:name => "mybot"))

    Deployment.create create_data.merge(:name_with_owner => "atmos/heaven")

    present << Deployment.create(create_data.merge(:environment => "staging"))

    deployments = Deployment.latest_for_name_with_owner("github/hubot")

    expect(deployments.size).to be 3
    expect(deployments).to match_array(present)
  end
end
