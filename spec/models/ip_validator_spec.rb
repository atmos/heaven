require "spec_helper"

describe IpValidator do
  context "verifies IPs" do
    it "returns production" do
      expect(IpValidator.new("127.0.0.1")).to_not be_valid
      expect(IpValidator.new("192.30.252.41")).to be_valid
      expect(IpValidator.new("192.30.252.46")).to be_valid
    end
  end
end
