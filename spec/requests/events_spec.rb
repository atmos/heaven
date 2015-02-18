require "request_spec_helper"

describe "Receiving GitHub hooks", :request do
  include FixtureHelper

  before do
    stub_gists
    stub_deploy_statuses
  end

  describe "POST /events" do
    it "returns a forbidden error to invalid hosts" do
      github_event("ping")

      post "/events", fixture_data("ping"), request_env("74.125.239.105")

      expect(last_response).to be_forbidden
      expect(last_response.status).to eql(403)
    end

    it "returns a unprocessable error for invalid events" do
      github_event("invalid")

      post "/events", "{}", request_env

      expect(last_response.status).to eql(422)
    end

    it "handles ping events from valid hosts" do
      github_event("ping")

      post "/events", fixture_data("ping"), request_env

      expect(last_response).to be_successful
      expect(last_response.status).to eql(201)
    end

    it "handles deployment events from valid hosts" do
      github_event("deployment")

      post "/events", fixture_data("deployment"), request_env

      expect(last_response).to be_successful
      expect(last_response.status).to eql(201)
    end

    it "handles deployment status events from valid hosts" do
      github_event("deployment_status")

      post "/events", fixture_data("deployment-success"), request_env

      expect(last_response).to be_successful
      expect(last_response.status).to eql(201)
    end
  end
end
