# GitHub -> Heroku

[![Build Status](https://travis-ci.org/tampopo/heroku-deploy.png?branch=master)](https://travis-ci.org/tampopo/heroku-deploy)

Receives deployment events from GitHub, ships to heroku.

# Running Locally

    $ bundle install --local --path vendor/gems
    $ bundle exec foreman

# Hosting on heroku

    $ heroku addons:add openredis:micro
    $ heroku ps:scale worker=2
    $ heroku config:add GITHUB_CLIENT_ID=<key>
    Setting config vars and restarting heroku-deployer... done, v8
    GITHUB_CLIENT_ID: <key>
    $ heroku config:add GITHUB_CLIENT_SECRET=<secret>
    Setting config vars and restarting heroku-deployer... done, v9
    GITHUB_CLIENT_SECRET: <secret>
    $

### Environmental Variables

* `GITHUB_DEPLOY_TOKEN`: A personal access token from your [account settings](https://github.com/settings/applications), for cloning.
* `HEROKU_DEPLOY_PRIVATE_KEY`: Your private ssh key that is allowed to push to heroku
