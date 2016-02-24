web: bundle exec unicorn -p $PORT -c config/unicorn.rb
worker: TERM_CHILD=1 bundle exec resque-pool
