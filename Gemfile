ruby '2.0.0'
source 'https://rubygems.org'

gem "dpl",      "1.5.7"
gem "rails",    "~>4.0.0"
gem "resque"
gem "unicorn"
gem "yajl-ruby"
gem "heroku-api"
gem "rendezvous"
gem "warden-github-rails"

# Pre-release for the deployments API
gem "octokit", :github => "atmos/octokit.rb", :ref => "6b1f968b"

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem "pry"
  gem "sqlite3"
  gem "webmock"
  gem "debugger"
  gem "rspec-rails"
end

group :development do
  gem "foreman"
  gem "meta_request"
  gem "better_errors"
  gem "binding_of_caller"
end

group :staging, :production do
  gem "pg"
  gem "rails_12factor"
end
