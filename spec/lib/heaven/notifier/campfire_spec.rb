require "spec_helper"

describe "Heaven::Notifier::Campfire" do
  include FixtureHelper

  it "handles pending notifications" do
    data = decoded_fixture_data("deployment-pending")

    n = Heaven::Notifier::Campfire.new(data)
    expect(n.default_message).to \
      eql "[atmos](https://github.com/atmos) is deploying [my-robot](https://github.com/atmos/my-robot/tree/break-up-notifiers) to production"
  end

  it "handles successful deployment statuses" do
    data = decoded_fixture_data("deployment-success")

    n = Heaven::Notifier::Campfire.new(data)
    expect(n.default_message).to \
      eql "[atmos](https://github.com/atmos)'s production deployment of [my-robot](https://github.com/atmos/my-robot) is done! "
  end

  it "handles failure deployment statuses" do
    data = decoded_fixture_data("deployment-failure")

    n = Heaven::Notifier::Campfire.new(data)
    expect(n.default_message).to \
      eql "[atmos](https://github.com/atmos)'s production deployment of [my-robot](https://github.com/atmos/my-robot) failed. "
  end
end
