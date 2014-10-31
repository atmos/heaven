# Heaven [![Build Status](https://travis-ci.org/atmos/heaven.png?branch=master)](https://travis-ci.org/atmos/heaven)

Heaven is an API that integrates with GitHub's [Deployment API][1]. It receives [deployment events][5] from GitHub and pushes code to your servers.

Heaven currently supports [capistrano][15], [fabric][10], and [heroku][22] deployments. It also has a notification system for broadcasting  [deployment status events][6] to chat services(e.g., [campfire][7],[hipchat][8], [SlackHQ][9], and [Flowdock][21]).  It can be hosted on heroku for a few dollars a month.

# Documentation

* [Overview](/doc/overview.md)
* [Installation](/doc/installation.md)
* [Deployment Providers](/doc/providers.md)
* [Deployment Notifications](/doc/notifications.md)
* [Environment Locking](/doc/locking.md)

# Launch on Heroku

[![Launch on Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

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
[21]: https://www.flowdock.com/
[22]: https://www.heroku.com
