require "spec_helper"

describe ApiClient do
  class ApiClientTester
    include ApiClient
  end

  it "makes instance methods available" do
    klass = ApiClientTester.new
    expect(klass.api).to_not be_nil
    expect(klass.github_token).to_not be_nil
  end
end
