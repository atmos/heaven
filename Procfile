web: bundle exec unicorn -p $PORT
worker: QUEUE=* bundle exec rake resque:work
