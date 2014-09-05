require "spec_helper"

describe "app.json config for heroku" do
  it "doesn't blow up parsing" do
    app_file = File.expand_path("../../app.json", __FILE__)
    data = JSON.parse(File.read(app_file))
    expect(data["name"]).to eql("Heaven")
  end
end
