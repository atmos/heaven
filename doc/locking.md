# Environment Locking

Most deployment commands are passed through to the deployment provider. One
exception to this norm, is when locking or unlocking an app environment.

`deploy:lock` and `deploy:unlock` tasks are intercepted and handled within
Heaven, never touching a provider. This allows for uniform locking behavior,
regardless of which providers you're using.

## Locking an environment

To lock an environment, set the `deploy:lock` task on a new deployment.

Once an environment is locked, any following deployments to the same app
environment will error out. If you have enabled a notifier, you will be sent an
error description including who locked the environment.

## Unlocking an environment

When you're ready to unlock an environment, set the `deploy:unlock` task on a
new deployment.

Once the deployment succeeds, the app environment will be available for new
deployments!
