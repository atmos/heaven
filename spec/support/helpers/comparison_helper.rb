module ComparisonHelper
  def build_commit_hash(message)
    {
      :sha => "sha",
      :commit => {
        :message => message
      },
      :author => {
        :login => "login",
        :html_url => "https://github.com/login"
      },
      :html_url => "https://github.com/org/repo/commit/sha"
    }
  end
end
