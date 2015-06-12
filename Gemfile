ruby "2.2.2"
source "https://rubygems.org"

gem "rails",    "~>4.2.1"
gem "resque"
gem "resque-lock-timeout"
gem "octokit"
gem "unicorn"
gem "yajl-ruby"
gem "posix-spawn"
gem "warden-github-rails"
gem "faraday"
gem "faraday_middleware"

# Providers
gem "dpl",        "1.5.7"
gem "aws-sdk"
gem "capistrano", "2.9.0"

# Notifiers
gem "hipchat"
gem "campfiyah"
gem "slack-notifier"
gem "flowdock"

group :test do
  gem "sqlite3", "1.3.10"
  gem "webmock"
  gem "simplecov", "0.7.1"
  gem "rubocop"
  gem "rspec-rails"
end

group :development do
  gem "pry"
  gem "foreman"
  gem "meta_request"
  gem "better_errors"
  gem "binding_of_caller"
end

group :staging, :production do
  gem "pg"
  gem "rails_12factor"
end
