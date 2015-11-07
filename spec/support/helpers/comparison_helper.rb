module ComparisonHelper
  def build_commit_double(message)
    double(
      :sha => "sha",
      :commit => double(
        :message => message
      ),
      :author => double(
        :login => "login",
        :html_url => "https://github.com/login"
      ),
      :html_url => "https://github.com/org/repo/commit/sha"
    )
  end
end
