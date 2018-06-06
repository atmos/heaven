# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
ENV["RAILS_SECRET_KEY_BASE"] ||= SecureRandom.hex

require File.expand_path("../../config/environment", __FILE__)
require "simplecov"
SimpleCov.start "rails"

require "rspec/rails"
require "rspec/autorun"
require "webmock/rspec"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

ENV["DEPLOYMENT_PRIVATE_KEY"] = "private\nkey\n"

RSpec.configure do |config|
  config.include GistHelper
  config.include DeploymentStatusHelper

  config.order = "random"
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before do
    ENV["GITHUB_CLIENT_ID"]     = "<unknown-client-id>"
    ENV["GITHUB_CLIENT_SECRET"] = "<unknown-client-secret>"
    Resque.inline = true
  end

  config.around do |example|
    original = Heaven.redis.client.db
    Heaven.redis.select(15)
    example.run
    Heaven.redis.flushall
    Heaven.redis.select(original)
  end
end

Heaven.testing = true
