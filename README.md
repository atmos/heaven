# GitHub -> Heroku [![Build Status](https://travis-ci.org/atmos/heaven.png?branch=master)](https://travis-ci.org/atmos/heaven)

Receives deployment events from GitHub, ships to heroku. Here's how it all fits together.

I use this with [hubot-deploy](https://github.com/atmos/hubot-deploy).

```
+---------+             +--------+            +----------+         +-------------+
|  Hubot  |             | GitHub |            |  Heaven  |         | Your Server |
+---------+             +--------+            +----------+         +-------------+
     |                      |                       |                     |
     |  Create Deployment   |                       |                     |
     |--------------------->|                       |                     |
     |                      |                       |                     |
     |  Deployment Created  |                       |                     |
     |<---------------------|                       |                     |
     |                      |                       |                     |
     |                      |   Deployment Event    |                     |
     |                      |---------------------->|                     |
     |                      |                       |     SSH+Deploys     |
     |                      |                       |-------------------->|
     |                      |                       |                     |
     |                      |   Deployment Status   |                     |
     |                      |<----------------------|                     |
     |                      |                       |                     |
     |                      |                       |   Deploy Completed  |
     |                      |                       |<--------------------|
     |                      |                       |                     |
     |                      |   Deployment Status   |                     |
     |                      |<----------------------|                     |
     |                      |                       |                     |

```


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
    $ heroku config:add RAILS_SECRET_KEY_BASE=`ruby -rsecurerandom -e "print SecureRandom.hex"`
    RAILS_SECRET_KEY_BASE: <secret>

## Environmental Variables

* `RAILS_SECRET_KEY_BASE`: The key configured in [secret_token.rb](/config/initializers/secret_token.rb).
* `GITHUB_TEAM_ID`: The GitHub team id to restrict resque access to.
* `GITHUB_DEPLOY_TOKEN`: A personal access token from your [account settings](https://github.com/settings/applications), for cloning.
* `HEROKU_DEPLOY_PRIVATE_KEY`: Your private ssh key that is allowed to push to heroku
