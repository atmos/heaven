require 'spec_helper'
require 'heaven/comparison/linked'

describe 'Heaven::Comparison::Linked' do
  let(:comparison) do
    {
      html_url: 'https://github.com/org/repo/compare/sha...sha',
      total_commits: 1,
      commits: [{
        sha: 'sha',
        commit: {
          message: 'Commit message #123'
        },
        author: {
          login: 'login',
          html_url: 'https://github.com/login'
        },
        html_url: 'https://github.com/org/repo/commit/sha'
      }],
      files: [{
        additions: 1,
        deletions: 2,
        changes: 3
      },{
        additions: 1,
        deletions: 2,
        changes: 3
      }]
    }.with_indifferent_access
  end

  describe '#changes' do
    it 'prints out a formatted and linked list of commit changes' do
      formatter  = Heaven::Comparison::Linked.new(comparison, 'org/repo')

      expect(formatter.changes).to eq(
        <<-CHANGES.strip_heredoc.strip
          Total Commits: 1 ([compare](https://github.com/org/repo/compare/sha...sha))
          2 Additions, 4 Deletions, 6 Changes

          [sha](https://github.com/org/repo/commit/sha) by [login](https://github.com/login): Commit message [#123](https://github.com/org/repo/issues/123)
        CHANGES
      )
    end
  end
end
