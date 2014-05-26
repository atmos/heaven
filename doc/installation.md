# Installation

Heaven was written as proof of concept for [GitHub's Deployment API][1]. 

Heaven was designed to be hosted on heroku. You can run multiple installs of it if you need one to be run internally  and be customizable It's designed to be hosted on 

## Hosting on heroku

### Process Management

You need redis for resque and as many workers as you think you'll need. I'd keep it at one until you start to notice queuing.

    $ heroku addons:add openredis:micro
    $ heroku ps:scale worker=1

### Configuration

Set the follow environmental variables are present `heroku config:add` like this.

```shell
$ heroku config:add GITHUB_TOKEN=<key>
Setting config vars and restarting heaven... done, v7
GITHUB_TOKEN: <key>
```

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| DATABASE_URL            | A uri for to connect to a postgresql database.  |
| GITHUB_TOKEN            | A personal access token from your [account settings][16], for API interaction.    |
| GITHUB_CLIENT_ID        | The client id of the OAuth application.         |
| GITHUB_CLIENT_SECRET    | The client secret of the OAuth application.     |
| GITHUB_TEAM_ID          | A GitHub team id to restrict resque access to.  |
| RAILS_SECRET_KEY_BASE   | The secret key for signing session cookies. This should be unique per domain.               |

### Optional Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| DEPLOYMENT_PRIVATE_KEY  | An ssh private key used to login to your remote servers via SSH. Put it all on one line with    `\n` in it.|
| DEPLOYMENT_TIMEOUT      | A timeout in seconds that the deployment should take. Deployments are aborted if they exceed   this value. Defaults to 300 seconds |
| HEROKU_API_KEY          | A [direct authorization][17] token from heroku  |

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
