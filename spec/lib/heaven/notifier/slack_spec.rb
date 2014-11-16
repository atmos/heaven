require "spec_helper"

describe "Heaven::Notifier::Slack" do
  include FixtureHelper

  it "handles pending notifications" do
    Heaven.redis.set("atmos/my-robot-production-revision", "sha")

    data = decoded_fixture_data("deployment-pending")

    n = Heaven::Notifier::Slack.new(data)
    n.comparison = {
      "html_url" => "https://github.com/org/repo/compare/sha...sha"
    }

    result = [
      "[#123456](https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c) ",
      ": [atmos](https://github.com/atmos) is deploying ",
      "[my-robot](https://github.com/atmos/my-robot/tree/break-up-notifiers) ",
      "to production ([compare](https://github.com/org/repo/compare/sha...sha))"
    ]

    expect(n.default_message).to eql result.join("")
  end

  it "handles successful deployment statuses" do
    data = decoded_fixture_data("deployment-success")

    n = Heaven::Notifier::Slack.new(data)

    result = [
      "[#11627](https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c) ",
      ": [atmos](https://github.com/atmos)'s production deployment of ",
      "[my-robot](https://github.com/atmos/my-robot) ",
      "is done! "
    ]
    expect(n.default_message).to eql result.join("")
  end

  it "handles failure deployment statuses" do
    data = decoded_fixture_data("deployment-failure")

    n = Heaven::Notifier::Slack.new(data)

    result = [
      "[#123456](https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c) ",
      ": [atmos](https://github.com/atmos)'s production deployment of ",
      "[my-robot](https://github.com/atmos/my-robot) ",
      "failed. "
    ]
    expect(n.default_message).to eql result.join("")
  end
end
