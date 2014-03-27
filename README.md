# Heaven [![Build Status](https://travis-ci.org/atmos/heaven.png?branch=master)](https://travis-ci.org/atmos/heaven)

Heaven is a rails app that receives [Deployment][1] events from GitHub and deploys your code to heroku.

It works really well with [hubot-deploy](https://github.com/atmos/hubot-deploy).

![](https://f.cloud.github.com/assets/38/2330090/208fce50-a42a-11e3-94e6-46beaac78bfb.jpg)

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

Configure it from a [GitHub Webhook][2] and it processes incoming payloads with [resque][3]. Heaven stores the shell output to a [gist][4].

Heaven is just an example of what a [webhook listener][2] on a repo can do. You can set up as many systems as you need to handle your web, mobile, native, compiled, and docker images while keeping the tooling the same. You can also start evaluating new systems on a per-repo basis without introducing widespread breakage across a deployment systems userbase.

# Hosting on heroku

You need redis for resque and as many workers as you think you'll need. I'd keep it at one until you start to notice queuing.

    $ heroku addons:add openredis:micro
    $ heroku ps:scale worker=1
    $ heroku config:add GITHUB_CLIENT_ID=<key>
    Setting config vars and restarting heaven... done, v8
    GITHUB_CLIENT_ID: <key>
    $ heroku config:add GITHUB_CLIENT_SECRET=<secret>
    Setting config vars and restarting heaven... done, v9
    GITHUB_CLIENT_SECRET: <secret>
    $ heroku config:add RAILS_SECRET_KEY_BASE=`ruby -rsecurerandom -e "print SecureRandom.hex"`
    RAILS_SECRET_KEY_BASE: <secret>

## Extra Environmental Variables

* `GITHUB_TEAM_ID`: The GitHub team id to restrict resque access to.
* `GITHUB_DEPLOY_TOKEN`: A personal access token from your [account settings](https://github.com/settings/applications), for cloning.

# See Also

* [hubot-deploy](https://github.com/atmos/hubot-deploy) - Kick off deployments from chat.
* [heaven-notifier](https://github.com/atmos/heaven-notifier) - Listens for DeploymentStatus events from GitHub and notifies you.

[1]: http://developer.github.com/v3/repos/deployments/
[2]: https://github.com/blog/1778-webhooks-level-up
[3]: https://github.com/resque/resque
[4]: https://gist.github.com/
