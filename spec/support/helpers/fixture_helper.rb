module FixtureHelper
  def fixture_data(name)
    path = Rails.root.join("spec", "fixtures", "#{name}.json")
    File.read(path)
  end

  def decoded_fixture_data(name)
    JSON.parse(fixture_data(name))
  end
end
