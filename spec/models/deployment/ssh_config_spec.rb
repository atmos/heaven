require "spec_helper"

describe Deployment::SshConfig do
  it "knows the path" do
    root = "#{Dir.pwd}/tmp"
    config = Deployment::SshConfig.new(File.expand_path("../../../../tmp", __FILE__))
    expect(config.root).to eql(root)
    expect(config.path).to eql("#{root}/.ssh")
    expect(config.config_path).to eql("#{root}/.ssh/config")
    expect(config.private_key_path).to eql("#{root}/.ssh/id_rsa")
    expect(config.git_ssh_path).to eql("#{root}/git-ssh")

    expect{ config.configure! }.to_not raise_error
  end
end
