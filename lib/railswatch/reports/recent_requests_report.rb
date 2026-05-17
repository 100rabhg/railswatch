# frozen_string_literal: true

module Railswatch
  module Reports
    class RecentRequestsReport < BaseReport
      def data
        time_ago = Railswatch.recent_requests_time_window.ago
        db.where('occurred_at > ?', time_ago)
          .order(occurred_at: :desc)
          .limit(limit)
          .map(&:record_hash)
      end

      private

      def limit
        Railswatch.recent_requests_limit ? Railswatch.recent_requests_limit.to_i : 100_000
      end
    end
  end
end
