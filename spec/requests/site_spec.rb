require "spec_helper"

describe "visiting in a browser" do
  it "redirects to github.com" do
    get "/"
    expect(response).to be_redirect
    expect(response.headers["Location"]).to eq("https://github.com/atmos/heaven")
  end
end
