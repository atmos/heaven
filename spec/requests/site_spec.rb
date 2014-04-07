require 'spec_helper'

describe "visiting in a browser" do
  it "redirects to github.com" do
    get "/"
    expect(response).to be_redirect

    headers = response.headers
    expect(headers['Location']).to eq("https://github.com/atmos/heaven")
    expect(headers['X-Frame-Options']).to eq("DENY")
    expect(headers['X-XSS-Protection']).to eq("1; mode=block")
    expect(headers['X-Content-Type-Options']).to eq("nosniff")
  end

  it "authenticates resque against github.com" do
    pending
    get "/resque"
    expect(response).to be_redirect
    expect(response.headers['Location']).to eq("https://github.com/atmos/heaven")
  end
end
