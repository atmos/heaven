require "spec_helper"

describe Deployment::Credentials do
  it "correctly sets up the environment" do
    root = "#{Dir.pwd}/tmp"
    credentials = Deployment::Credentials.new(root)

    expect{ credentials.setup! }.to_not raise_error
    expect(File.exists?("#{root}/.netrc")).to be true
    expect(File.exists?("#{root}/.ssh/config")).to be true
    expect(File.exists?("#{root}/.ssh/id_rsa")).to be true
  end
end
