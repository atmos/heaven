require "spec_helper"

describe "visiting in a browser" do
  it "redirects to github.com" do
    get "/"
    expect(last_response).to be_redirect
    expect(last_response.headers["Location"]).to eq("https://github.com/atmos/heaven")
  end
end
