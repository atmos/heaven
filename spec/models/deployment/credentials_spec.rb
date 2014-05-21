require "spec_helper"

describe Deployment::Credentials do
  it "knows the path" do
    root = "#{Dir.pwd}/tmp"
    tmpdir = File.expand_path("../../../../tmp", __FILE__)

    credentials = Deployment::Credentials.new(tmpdir)
    expect(credentials.root).to eql(root)
    expect(credentials.ssh_key).to eql("#{root}/.ssh/id_rsa")
    expect(credentials.ssh_config).to eql("#{root}/.ssh/config")
    expect(credentials.netrc_config).to eql("#{root}/.netrc")

    expect{ credentials.setup! }.to_not raise_error
  end
end
