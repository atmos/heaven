require "spec_helper"

describe Repository do
  it "creates simple repositories" do
    repository = Repository.create :name => "heaven", :owner => "atmos"

    expect(repository).to be_valid
    expect(repository).to be_active
  end
end
