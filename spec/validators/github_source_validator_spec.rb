require "spec_helper"

describe GithubSourceValidator do
  include MetaHelper

  before { stub_meta }

  context "verifies IPs" do
    it "returns production" do
      expect(GithubSourceValidator.new("127.0.0.1")).to_not be_valid
      expect(GithubSourceValidator.new("192.30.252.41")).to be_valid
      expect(GithubSourceValidator.new("192.30.252.46")).to be_valid
    end
  end
end
