ruby '2.0.0'
source 'https://rubygems.org'

gem "rails",    "~>4.1.0"
gem "resque"
gem "resque-lock-timeout"
gem "octokit"
gem "unicorn"
gem "yajl-ruby"
gem "posix-spawn"
gem "warden-github-rails"

# Providers
gem "dpl",        "1.5.7"
gem "capistrano", "2.9.0"

# Notifiers
gem "hipchat"
gem "campfiyah"
gem "slack-notifier"
gem "flowdock"

group :development, :test do
  gem "pry"
  gem "sqlite3"
  gem "webmock"
  gem "debugger"
  gem "simplecov"
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
