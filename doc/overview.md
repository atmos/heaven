# Overview

Heaven is a rails app that receives [Deployment][1] events from GitHub and deploys your code. It works best with a [hubot](https://hubot.github.com), and give you a [chat-ops][20] style workflow. It receives [GitHub webhooks][2] and runs deployment jobs as background tasks with [resque][3].  Heaven captures the standard input and output streams and posts the results to a [gist][4].

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

Heaven aims to give you [GitHub Flow](https://guides.github.com/introduction/flow/index.html). It allows you to deploy branches easily and always roll back to master.

The goal of heaven is to be one of many deployment systems that you can use with the Deployments API. It's a small app that receives [webhooks][2] for specific repositories. You can set up as many systems as you need to handle your web, mobile, native, compiled, and docker images while keeping the tooling the same through GitHub. You can also start evaluating new systems on a per-repo basis without introducing widespread breakage across a deployment systems userbase.

If you deploy from chat then this all starts to feel pretty natural.

![](https://f.cloud.github.com/assets/38/2330090/208fce50-a42a-11e3-94e6-46beaac78bfb.jpg)


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
