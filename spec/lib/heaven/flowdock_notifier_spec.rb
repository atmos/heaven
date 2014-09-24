require "spec_helper"

describe "Heaven::Notifier::Flowdock" do
  it "handles pending notifications" do
    n = Heaven::Notifier::Flowdock.new(fixture_data("deployment-pending"))
    expect(n.default_message).to \
      eql "Deploying my-robot#break-up-notifiers (https://github.com/atmos/my-robot/tree/break-up-notifiers) to production. "
  end

  it "handles successful deployment statuses" do
    n = Heaven::Notifier::Flowdock.new(fixture_data("deployment-success"))
    expect(n.default_message).to \
      eql "Deployment of my-robot#break-up-notifiers (https://github.com/atmos/my-robot) to production is done! "
  end

  it "handles failure deployment statuses" do
    n = Heaven::Notifier::Flowdock.new(fixture_data("deployment-failure"))
    expect(n.default_message).to \
      eql "Deployment of my-robot#break-up-notifiers (https://github.com/atmos/my-robot) to production failed. "
  end

  it "does not show default branch" do
    data = JSON.parse fixture_data("deployment-pending")
    data["deployment"]["ref"] = 'master'
    n = Heaven::Notifier::Flowdock.new(JSON.dump(data))
    expect(n.default_message).to \
      eql "Deploying my-robot (https://github.com/atmos/my-robot/tree/master) to production. "
  end
end
