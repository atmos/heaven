module EnvironmentLocker::Matchers
  extend RSpec::Matchers::DSL

  matcher :be_locked do
    match do |environment_key|
      Heaven.redis.exists("#{environment_key}-lock")
    end
  end
end
