# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "octokit"
  s.version = "3.0.0.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wynn Netherland", "Erik Michaels-Ober", "Clint Shryock"]
  s.date = "2014-02-21"
  s.description = "Simple wrapper for the GitHub API"
  s.email = ["wynn.netherland@gmail.com", "sferik@gmail.com", "clint@ctshryock.com"]
  s.files = [".document", "CONTRIBUTING.md", "LICENSE.md", "README.md", "Rakefile", "octokit.gemspec", "lib/octokit/arguments.rb", "lib/octokit/authentication.rb", "lib/octokit/backports/uri.rb", "lib/octokit/client/authorizations.rb", "lib/octokit/client/commit_comments.rb", "lib/octokit/client/commits.rb", "lib/octokit/client/contents.rb", "lib/octokit/client/deployments.rb", "lib/octokit/client/downloads.rb", "lib/octokit/client/emojis.rb", "lib/octokit/client/events.rb", "lib/octokit/client/feeds.rb", "lib/octokit/client/gists.rb", "lib/octokit/client/gitignore.rb", "lib/octokit/client/hooks.rb", "lib/octokit/client/issues.rb", "lib/octokit/client/labels.rb", "lib/octokit/client/legacy_search.rb", "lib/octokit/client/markdown.rb", "lib/octokit/client/meta.rb", "lib/octokit/client/milestones.rb", "lib/octokit/client/notifications.rb", "lib/octokit/client/objects.rb", "lib/octokit/client/organizations.rb", "lib/octokit/client/pages.rb", "lib/octokit/client/pub_sub_hubbub.rb", "lib/octokit/client/pull_requests.rb", "lib/octokit/client/rate_limit.rb", "lib/octokit/client/refs.rb", "lib/octokit/client/releases.rb", "lib/octokit/client/repositories.rb", "lib/octokit/client/say.rb", "lib/octokit/client/search.rb", "lib/octokit/client/service_status.rb", "lib/octokit/client/stats.rb", "lib/octokit/client/statuses.rb", "lib/octokit/client/users.rb", "lib/octokit/client.rb", "lib/octokit/configurable.rb", "lib/octokit/default.rb", "lib/octokit/error.rb", "lib/octokit/gist.rb", "lib/octokit/rate_limit.rb", "lib/octokit/repo_arguments.rb", "lib/octokit/repository.rb", "lib/octokit/response/feed_parser.rb", "lib/octokit/response/raise_error.rb", "lib/octokit/version.rb", "lib/octokit.rb"]
  s.homepage = "https://github.com/octokit/octokit.rb"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Ruby toolkit for working with the GitHub API"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_runtime_dependency(%q<sawyer>, ["~> 0.5.3"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<sawyer>, ["~> 0.5.3"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<sawyer>, ["~> 0.5.3"])
  end
end
