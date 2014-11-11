module Heaven
  module Comparison
    # Formats a comparison between two commits
    class Default
      attr_reader :comparison

      def initialize(comparison)
        @comparison = comparison.with_indifferent_access
      end

      def changes(limit = nil)
        header  = changes_header
        commits = comparison[:commits].reverse

        commit_list = formatted_commits(limit ? commits.take(limit) : commits)

        parts = [header, commit_list]

        if limit && limit < commits.length
          parts << n_more_commits_link(commits.length - limit)
        end

        parts.join("\n")
      end

      private

      def changes_header
        <<-CHANGES.strip_heredoc
          Total Commits: #{total_commits}
          #{file_sum(:additions)} Additions, #{file_sum(:deletions)} Deletions, #{file_sum(:changes)} Changes
        CHANGES
      end

      def n_more_commits_link(number)
        "And #{number} more #{"commit".pluralize(number)}... #{comparison[:html_url]}"
      end

      def total_commits
        comparison[:total_commits]
      end

      def file_sum(key)
        comparison[:files].map { |f| f[key] }.reduce(&:+) || 0
      end

      def formatted_commits(commits)
        commits.map do |commit|
          "#{commit[:sha][0..7]} by #{commit[:author][:login]}: #{commit_message(commit[:commit])}"
        end
      end

      def commit_message(commit)
        commit[:message].split("\n").first
      end
    end
  end
end
