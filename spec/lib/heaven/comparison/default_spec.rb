require "spec_helper"
require "heaven/comparison/default"
require "support/helpers/comparison_helper"

describe "Heaven::Comparison::Default" do
  include ComparisonHelper

  let(:comparison) do
    {
      :html_url => "https://github.com/org/repo/compare/sha...sha",
      :total_commits => 1,
      :commits => [
        build_commit_hash("Commit message #123"),
        build_commit_hash("Another commit")
      ],
      :files => [{
        :additions => 1,
        :deletions => 2,
        :changes => 3
      }, {
        :additions => 1,
        :deletions => 2,
        :changes => 3
      }]
    }.with_indifferent_access
  end

  describe "#changes" do
    it "prints out a formatted list of commit changes" do
      formatter  = Heaven::Comparison::Default.new(comparison)

      expect(formatter.changes).to eq(
        <<-CHANGES.strip_heredoc.strip
          Total Commits: 1
          2 Additions, 4 Deletions, 6 Changes

          sha by login: Another commit
          sha by login: Commit message #123
        CHANGES
      )
    end

    it "accepts a commit list limit" do
      formatter  = Heaven::Comparison::Default.new(comparison)

      expect(formatter.changes(1)).to eq(
        <<-CHANGES.strip_heredoc.strip
          Total Commits: 1
          2 Additions, 4 Deletions, 6 Changes

          sha by login: Another commit
          And 1 more commit... https://github.com/org/repo/compare/sha...sha
        CHANGES
      )
    end
  end
end
