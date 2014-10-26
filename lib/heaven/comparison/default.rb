require 'active_support/core_ext/hash/indifferent_access'

module Heaven
  module Comparison
    class Default
      attr_reader :comparison

      def initialize(comparison)
        @comparison = comparison.with_indifferent_access
      end

      def changes
        header  = changes_header
        commits = formatted_commits(comparison[:commits])

        [header, commits].join("\n")
      end

      private

      def changes_header
        <<-CHANGES.strip_heredoc
          Total Commits: #{total_commits}
          #{file_sum(:additions)} Additions, #{file_sum(:deletions)} Deletions, #{file_sum(:changes)} Changes
        CHANGES
      end

      def total_commits
        comparison[:total_commits]
      end

      def file_sum(key)
        comparison[:files].map { |f| f[key] }.reduce(&:+) || 0
      end

      def formatted_commits(commits)
        commits.reverse.map do |commit|
          "#{commit[:sha]} by #{commit[:author][:login]}: #{commit_message(commit[:commit])}"
        end
      end

      def commit_message(commit)
        commit[:message].split("\n").first
      end
    end
  end
end
