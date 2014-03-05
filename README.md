# Heaven [![Build Status](https://travis-ci.org/atmos/heaven.png?branch=master)](https://travis-ci.org/atmos/heaven)

Heaven is a rails app that receives [Deployment][1] events from GitHub and deploys your code to heroku.

It works really well with [hubot-deploy](https://github.com/atmos/hubot-deploy).

You configure it via a [GitHub Webhook][2] and it processes incoming payloads with [resque][3].

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

# Hosting on heroku

    $ heroku addons:add openredis:micro
    $ heroku ps:scale worker=1
    $ heroku config:add GITHUB_CLIENT_ID=<key>
    Setting config vars and restarting heroku-deployer... done, v8
    GITHUB_CLIENT_ID: <key>
    $ heroku config:add GITHUB_CLIENT_SECRET=<secret>
    Setting config vars and restarting heroku-deployer... done, v9
    GITHUB_CLIENT_SECRET: <secret>
    $ heroku config:add RAILS_SECRET_KEY_BASE=`ruby -rsecurerandom -e "print SecureRandom.hex"`
    RAILS_SECRET_KEY_BASE: <secret>

## Extra Environmental Variables

* `GITHUB_TEAM_ID`: The GitHub team id to restrict resque access to.
* `GITHUB_DEPLOY_TOKEN`: A personal access token from your [account settings](https://github.com/settings/applications), for cloning.
* `HEROKU_DEPLOY_PRIVATE_KEY`: Your private ssh key that is allowed to push to heroku

# See Also

* [hubot-deploy](https://github.com/atmos/hubot-deploy) - Kick off deployments from chat.
* [heaven-notifier](https://github.com/atmos/heaven-notifier) - Listents for DeploymentStatus events from GitHub and notifies you.

[1]: http://developer.github.com/v3/repos/deployments/
[2]: https://github.com/blog/1778-webhooks-level-up
[3]: https://github.com/resque/resque
