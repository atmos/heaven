require "spec_helper"

describe "receiving GitHub hooks" do
  before do
    stub_gists
    stub_deploy_statuses
  end

  it "404s on events from invalid hosts" do
    post "/events", fixture_data("ping"), default_headers("ping", "74.125.239.105")

    expect(response).to be_not_found
    expect(response.status).to eql(404)
  end

  it "handles ping events from valid hosts" do
    post "/events", fixture_data("ping"), default_headers("ping")

    expect(response).to be_success
    expect(response.status).to eql(201)
  end

  it "handles deployment events from valid hosts" do
    pending "ugh"
    post "/events", fixture_data("deployment"), default_headers("deployment")

    expect(response).to be_success
    expect(response.status).to eql(201)
  end

  it "handles deployment status events from valid hosts" do
    post "/events", fixture_data("deployment-success"), default_headers("deployment_status")

    expect(response).to be_success
    expect(response.status).to eql(201)
  end
end
