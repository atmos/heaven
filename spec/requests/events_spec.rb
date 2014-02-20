require 'spec_helper'

describe "receiving GitHub hooks" do
  before do
    stub_gists
    stub_deploy_statuses
  end

  it "handles ping events" do
    post "/events", fixture_data("ping"), default_headers("ping")

    expect(response).to be_success
    expect(response.status).to eql(201)
  end

  it "handles deployment events" do
    post "/events", fixture_data("deployment"), default_headers("deployment")

    expect(response).to be_success
    expect(response.status).to eql(201)
  end
end
