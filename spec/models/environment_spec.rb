require "spec_helper"

describe Environment do
  it "doesn't recreate environments with the same name" do
    expect(Environment.create(name: "production")).to be_valid
    expect {
      Environment.create!(name: "production")
    }.to raise_exception
  end
end
