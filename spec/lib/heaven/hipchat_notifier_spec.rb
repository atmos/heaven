require "spec_helper"

describe "Heaven::Notifier::Hipchat" do
  include FixtureHelper

  it "handles pending notifications" do
    data = decoded_fixture_data("deployment-pending")

    n = Heaven::Notifier::Hipchat.new(data)
    expect(n.default_message).to \
      eql "@atmos is deploying https://github.com/atmos/my-robot/tree/break-up-notifiers to production"
  end

  it "handles successful deployment statuses" do
    data = decoded_fixture_data("deployment-success")

    n = Heaven::Notifier::Hipchat.new(data)
    expect(n.default_message).to \
      eql "@atmos's production deployment of https://github.com/atmos/my-robot is done! "
  end

  it "handles failure deployment statuses" do
    data = decoded_fixture_data("deployment-failure")

    n = Heaven::Notifier::Hipchat.new(data)
    expect(n.default_message).to \
      eql "@atmos's production deployment of https://github.com/atmos/my-robot failed. "
  end
end
