# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
if Rails.env.development?
  Heaven::Application.config.secret_key_base = '8d788e2c-b4b4-4013-9909-1364d53d0aa2'
else
  Heaven::Application.config.secret_key_base = ENV['RAILS_SECRET_KEY_BASE']
end
