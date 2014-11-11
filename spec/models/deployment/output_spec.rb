require "spec_helper"

describe Deployment::Output do
  let(:gist) { Octokit::Gist.new("deadbeef") }

  it "creates a gist for storing output" do
    params = {
      :files       => { :stdout => { :content => "Deployment 42 pending" } },
      :public      => false,
      :description => "Heaven number 42 for heaven"
    }

    stub_request(:post, "https://api.github.com/gists")
      .with(:body => params.to_json)
      .to_return(:status => 200, :body => gist, :headers => {})

    output = Deployment::Output.new("heaven", 42, SecureRandom.uuid)
    expect { output.create }.to_not raise_error

    params = {
      :files  => {
        :stderr => { :content => "chasing dreams" },
        :stdout => { :content => "push to limit" }
      },
      :public => false
    }

    stub_request(:patch, "https://api.github.com/gists/#{gist.id}")
      .with(:body => params.to_json)
      .to_return(:status => 200, :body => "", :headers => {})

    output.stderr = "chasing dreams"
    output.stdout = "push to limit"

    expect { output.update }.to_not raise_error
  end
end
