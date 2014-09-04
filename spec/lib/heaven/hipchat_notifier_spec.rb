require "spec_helper"

describe "Heaven::Notifier::Hipchat" do
  it "handles pending notifications" do
    n = Heaven::Notifier::Hipchat.new(fixture_data("deployment-pending"))
    expect(n.default_message).to \
      eql "@atmos is deploying https://github.com/atmos/my-robot/tree/break-up-notifiers to production"
  end

  it "handles successful deployment statuses" do
    n = Heaven::Notifier::Hipchat.new(fixture_data("deployment-success"))
    expect(n.default_message).to \
      eql "@atmos's production deployment of https://github.com/atmos/my-robot is done! "
  end

  it "handles failure deployment statuses" do
    n = Heaven::Notifier::Hipchat.new(fixture_data("deployment-failure"))
    expect(n.default_message).to \
      eql "@atmos's production deployment of https://github.com/atmos/my-robot failed. "
  end
end
