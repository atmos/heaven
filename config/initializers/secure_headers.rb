
::SecureHeaders::Configuration.configure do |config|
  config.csp = { :default_src => "'none'" }
  config.hsts = {:max_age => 20.years.to_i, :include_subdomains => true}
  config.x_content_type_options = "nosniff"
  config.x_frame_options = { :value => 'DENY' }
  config.x_xss_protection = {:value => 1, :mode => 'block'}
end
