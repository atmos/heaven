require 'heaven/comparison/default'

module Heaven
  module Comparison
    class Linked < Default
      attr_reader :name_with_owner

      def initialize(comparison, name_with_owner)
        @comparison      = comparison.with_indifferent_access
        @name_with_owner = name_with_owner
      end

      private

      def changes_header
        <<-CHANGES.strip_heredoc
          Total Commits: #{total_commits} (#{compare_link})
          #{file_sum(:additions)} Additions, #{file_sum(:deletions)} Deletions, #{file_sum(:changes)} Changes
        CHANGES
      end

      def compare_link
        "[compare](#{comparison[:html_url]})"
      end

      def formatted_commits(commits)
        commits.reverse.map do |commit|
          "#{sha_link(commit)} by #{author_link(commit[:author])}: #{commit_message(commit[:commit])}"
        end
      end

      def commit_message(commit)
        super.gsub(/#(\d+)/, "[#\\1](https://github.com/#{name_with_owner}/issues/\\1)")
      end

      def sha_link(commit)
        "[#{commit[:sha][0..7]}](#{commit[:html_url]})"
      end

      def author_link(author)
        "[#{author[:login]}](#{author[:html_url]})"
      end
    end
  end
end
