require "spec_helper"

describe Deployment::Status do
  it "knows whether or not it completed" do
    status = Deployment::Status.new("atmos/heaven", 42)

    expect(status).to_not be_completed
  end
end
