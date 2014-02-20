require "spec_helper"

describe Output do
  let(:gist) { Octokit::Gist.new("deadbeef") }

  it "creates a gist for storing output" do
    params = {
      :files => {:clone => {:content => "Deployment 42 pending" } },
      :public => false,
      :description => "HerokuDeploy number 42 for atmos-oiran"
    }

    stub_request(:post, "https://api.github.com/gists").
      with(:body => params.to_json).
      to_return(:status => 200, :body => gist, :headers => {})

    output = Output.new(42, "atmos-oiran", "nfi")
    expect { output.create }.to_not raise_error

    params = {
      :public => false,
      :files  => {
        :clone  => {:content => nil },
        :stdout => {:content => "push to limit" },
        :stderr => {:content => "chasing dreams" }
      }
    }

    stub_request(:patch, "https://api.github.com/gists/#{gist.id}").
      with(:body => params.to_json).
      to_return(:status => 200, :body => "", :headers => {})
    expect { output.update("push to limit", "chasing dreams") }.to_not raise_error
  end
end
