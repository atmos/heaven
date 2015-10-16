# Providers

A provider is an interface to taking code on GitHub at a specific sha and doing something with it. Heaven comes with two example providers that show off how to interact with HTTP APIs(heroku) as well as shelling out(capistrano). It should be easy to adapt to things like [fabric][10], [chef][11], and [puppet][12] as well.

All providers run inside of [resque][3] jobs and have a configurable timeout.

### Example Provider

```ruby
module Provider
  class Fabric < DefaultProvider
    def execute
    end

    def notify
    end
  end
end
```

### Timeouts

Jobs will timeout if they don't complete in 300 seconds. If you really need more than that you can configure the timeout by setting the `DEPLOYMENT_TIMEOUT` environmental variable to the number of seconds you'd like to increase it to.

Heaven runs most of the deployment tasks in a child process, that by default does not die when the deployment timeouts. To enable terminating the deployment child processes, set `TERMINATE_CHILD_PROCESS_ON_TIMEOUT` to `1`.

## Heroku

The heroku provider uses the [build and release API][13]. It requests an [archive link][14] from GitHub and passes that on to heroku. It polls the API every few seconds until the heroku build api completes.

### Required Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| HEROKU_API_KEY          | A [direct authorization][17] token from heroku  |

### Flow

```
+--------+            +----------+         +-------------+
| GitHub |            |  Heaven  |         |    Heroku   |
+--------+            +----------+         +-------------+
    |                       |                     |
    |   Deployment Event    |                     |
    |---------------------->|                     |
    |                       |                     |
    |                       |                     |
    | Request Download URL  |                     |
    |<----------------------|                     |
    |                       |                     |
    |                       |                     |
    | Expiring Tarball URL  |                     |
    |---------------------->|                     |
    |                       |                     |
    |                       |                     |
    |                       |    Create Build     |
    |                       |-------------------->|
    |                       |                     |
    |                       |                     |
    |   Deployment Status   |                     |
    |<----------------------|                     |
    |                       |                     |
    |                       |                     |
    |                       |    Request Status   |
    |                       |-------------------->|
    |                       |                     |
    |                       |                     |
    |                       |   Loops until done  |
    |                       |<--------------------|
    |                       |                     |
    |                       |                     |
    |   Deployment Status   |                     |
    |<----------------------|                     |
    |                       |                     |
```

## Capistrano

Capistrano gives you a distributed task management system over ssh. The heaven provider gives you support for three options in capistrano.

### Options

* environment
* branch
* task

### Required Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| DEPLOYMENT_PRIVATE_KEY  | An ssh private key used to login to your remote servers via SSH. Put it all on one line with    `\n` in it.|

You need to configure your `:repository` option in your Capfile to use an https remote. The git interactions will always be over https and the ssh interactions will only involve accessing your servers.


### Capfile

Below is a simple capfile that works with [passenger][18].

```ruby
require "bundler/capistrano"

default_run_options[:pty] = true

set :ruby_path, "/usr/local/rbenv/versions/1.9.3-p448/bin/"

set :application, "heaven"
set :default_environment, {
  'PATH'      => "#{ruby_path}:$PATH",
  'RAILS_ENV' => 'production'
}

set :scm, :git
set :branch, (ENV['CAP_BRANCH'] || 'master')
set :deploy_via, :remote_cache

set :repository,  "https://github.com/atmos/heaven"
set :user, "atmos"
set :use_sudo, false
set :ssh_options, {:forward_agent => true}

set :deploy_to, "/app/#{application}"

set :target_server, "mybox.mydomain.com"
role :app, target_server
role :web, target_server
role :db,  target_server, :primary => true

task :production do
end

namespace :deploy do
  desc "Run migrations"
  task :migrate, :roles => :db do
    run "cd #{current_path} && bin/rake db:migrate"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

```

### Flow

```
+--------+            +----------+         +-------------+
| GitHub |            |  Heaven  |         |   SSH Host  |
+--------+            +----------+         +-------------+
    |                       |                     |
    |   Deployment Event    |                     |
    |---------------------->|                     |
    |                       |                     |
    |                       |                     |
    |      Fetch ref/sha    |                     |
    |<----------------------|                     |
    |                       |                     |
    |                       |                     |
    |   Return latest ref   |                     |
    |---------------------->|                     |
    |                       |                     |
    |                       |                     |
    |                       |    SSH into host    |
    |                       |-------------------->|
    |                       |                     |
    |                       |                     |
    |   Deployment Status   |                     |
    |<----------------------|                     |
    |                       |                     |
    |                       |                     |
    |                       |   bundles/restarts  |
    |                       |<--------------------|
    |                       |                     |
    |                       |                     |
    |   Deployment Status   |                     |
    |<----------------------|                     |
    |                       |                     |
```

## Bundler Capistrano

Bundler enabled Capistrano deployment lets you deploy using Capistrano in a fresh bundler environment. The provider will install the gems from your project's `:deployment` and `:heaven` groups and use that environment to run Capistrano. The same configuration applies for Bundler Capistrano than for Capistrano provider. One caveat:

The provider passes the ref being deployed to capistrano in an environment variable `BRANCH`. In your `Capfile`, you'll need to add:

```ruby
set :branch, (ENV['BRANCH'] || fetch(:branch, 'master'))
```

| Environmental Variables     |                                                                                                 |
|-----------------------------|-------------------------------------------------------------------------------------------------|
| BUNDLER_PRIVATE_SOURCE      | Private gem source. _Optional._                                                                 |
| BUNDLER_PRIVATE_CREDENTIALS | Private gem source credentials. Can be a token or a username:password combination. _Optional._  |

## Fabric

Fabric enables distributed task management system over ssh. The heaven provider gives you support for three options.

### Options

* environment
* branch
* task

### Required Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| DEPLOYMENT_PRIVATE_KEY  | An ssh private key used to login to your remote servers via SSH. Put it all on one line with    `\n` in it.|

### Optional Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| DEPLOY_COMMAND_FORMAT   | Allows you to define the specific task calling format for your fabric file. Defaults to: `fab -R %{environment} %{task}:branch_name=%{ref}` |

## Elastic Beanstalk

With [Elastic beanstalk][21] you can quickly deploy and manage applications in
the AWS cloud without worrying about the infrastructure that runs those
applications.

### Options

* environment
* branch

### Required Configuration

| Environmental Variables        |                                                 |
|--------------------------------|-------------------------------------------------|
| BEANSTALK_S3_BUCKET            | The bucket to store s3 archives in.             |
| BEANSTALK_ACCESS_KEY_ID        | The AWS access key id for API interaction with Amazon. |
| BEANSTALK_SECRET_ACCESS_KEY    | The AWS secret access key for API interaction with Amazon. |

### Optional Configuration

| Environmental Variables |                                                 |
|-------------------------|-------------------------------------------------|
| | |

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
[21]: http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/Welcome.html

## Shell provider

Shell provider lets you run an arbitrary script from the repo to perform the deployment. The script receives `BRANCH`, `SHA`, `DEPLOY_TASK` and `DEPLOY_ENV` environment variables when executing. This is ideal provider if your deployment consists only of for example asset compilation and upload to S3.

### Required Configuration

No configuration required in heaven. You must add `"deploy_script"` key to your `apps.json` configuration that must point to an executable file inside the repository.
