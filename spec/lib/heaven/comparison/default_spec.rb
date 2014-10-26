require 'spec_helper'
require 'heaven/comparison/default'

describe 'Heaven::Comparison::Default' do
  let(:comparison) do
    {
      total_commits: 1,
      commits: [{
        sha: 'sha',
        commit: {
          message: 'Commit message'
        },
        author: {
          login: 'login',
        },
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
    it 'prints out a formatted list of commit changes' do
      formatter  = Heaven::Comparison::Default.new(comparison)

      expect(formatter.changes).to eq(
        <<-CHANGES.strip_heredoc.strip
          Total Commits: 1
          2 Additions, 4 Deletions, 6 Changes

          sha by login: Commit message
        CHANGES
      )
    end
  end
end
