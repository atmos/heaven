require "spec_helper"

describe "Heaven::Notifier::Default" do
  it "does not deliver changes unless an environment opt-in is present" do
    notifier = Heaven::Notifier::Default.new("{}")

    expect(notifier.change_delivery_enabled?).to be_false

    ENV["HEAVEN_NOTIFIER_DISPLAY_COMMITS"] = "true"

    notifier = Heaven::Notifier::Default.new("{}")

    expect(notifier.change_delivery_enabled?).to be_true
  end
end
