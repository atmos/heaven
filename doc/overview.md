# Overview

Heaven is a rails app that receives [Deployment][1] events from GitHub and deploys your code. It works best with a [hubot](https://hubot.github.com), and give you a [chat-ops][20] style workflow.

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

Heaven is just an example of what a [webhook listener][2] on a repo can do. You can set up as many systems as you need to handle your web, mobile, native, compiled, and docker images while keeping the tooling the same. You can also start evaluating new systems on a per-repo basis without introducing widespread breakage across a deployment systems userbase.

Configure it from a [GitHub Webhook][2] and it processes incoming payloads with [resque][3]. 

Heaven stores the shell output to a [gist][4].

[1]: http://developer.github.com/v3/repos/deployments/
[2]: https://github.com/blog/1778-webhooks-level-up
[3]: https://github.com/resque/resque
[4]: https://gist.github.com/
[5]: https://developer.github.com/v3/repos/deployments/#create-a-deployment
[6]: https://developer.github.com/v3/repos/deployments/#create-a-deployment-status
[7]: https://campfirenow.com/
[8]: https://www.hipchat.com/
[9]: https://slack.com/
[10]: http://www.fabfile.org/
[11]: http://www.getchef.com/
[12]: http://puppetlabs.com/
[13]: https://devcenter.heroku.com/articles/build-and-release-using-the-api
[14]: https://developer.github.com/v3/repos/contents/#get-archive-link
[15]: http://capistranorb.com/
[16]: https://github.com/settings/applications
[17]: https://devcenter.heroku.com/articles/oauth#direct-authorization
[18]: https://www.phusionpassenger.com/
[19]: https://devcenter.heroku.com/articles/releases
[20]: https://github.com/atmos/hubot-deploy
