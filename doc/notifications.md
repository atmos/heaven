# Chat Notifications

Heaven looks for information in the environments and tries to give feedback to chat rooms to everyone knows that code has been deployed. Right now it supports three networks.

All notifications run inside of [resque][3] jobs and need to define a deliver method.

### Example Provider

```ruby
module Heaven
  module Notifier
    class MyChat < Default
      def deliver(message)
      end
    end
  end
end
```

## SlackHQ

### Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| SLACK_TOKEN             | A Slack API token from [incoming-webhook][21] section of Slack|
| SLACK_SUBDOMAIN         | This subdomain for the slack chat. For example https://atmos.slack.com would be 'atmos'|

## Campfire

### Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| CAMPFIRE_TOKEN          | A campfire API token from the 'my info' section of [campfire][7].                               |
| CAMPFIRE_SUBDOMAIN      | This subdomain for the campfire. For example https://atmos.campfirenow.com would be 'atmos'  |

## HipChat

### Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| HIPCHAT_TOKEN           | The notification token to send messages to hipchat. |
| HIPCHAT_ROOM            | The room to post deployment messages to.        |

## Flowdock

### Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| FLOWDOCK_USER_API_TOKEN | A user's api token from Flowdock [account page][22]. This is used to access the api and post some messages. |
| FLOWDOCK_FLOW_TOKENS | A JSON string that has flow ids and [flow source tokens][23] as key-value pairs. You need to generate the source tokens using OAuth api. Note that these are part of the new [Flowdock threads api][24] and thus the old flow tokens will not work. |
| FLOWDOCK_USER_NAME | (Optional) A name that is displayed as the author for deployment activities. Defaults to `Heaven` |
| FLOWDOCK_USER_EMAIL | (Optional) An email address for the above user. Defaults to dummy `build@flowdock.com`. |
| FLOWDOCK_USER_AVATAR | (Optional) A url to an image that is shown for the above user as an avatar. By default a success and failure icon are used depending on the build status. |

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
[21]: https://my.slack.com/services/new/incoming-webhook
[22]: https://www.flowdock.com/account/tokens
[23]: https://gist.github.com/Mumakil/1d184a3f06bcd087c5e2
[24]: https://www.flowdock.com/api/how-to-integrate
