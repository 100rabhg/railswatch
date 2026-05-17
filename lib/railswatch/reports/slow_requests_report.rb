# frozen_string_literal: true

module Railswatch
  module Reports
    class SlowRequestsReport < BaseReport
      def data
        db.where('occurred_at > ?', Railswatch.slow_requests_time_window.ago)
          .where('duration_ms > ?', Railswatch.slow_requests_threshold.to_f)
          .order(occurred_at: :desc)
          .limit(limit)
          .map(&:record_hash)
      end

      private

      def limit
        Railswatch.slow_requests_limit ? Railswatch.slow_requests_limit.to_i : 100_000
      end
    end
  end
end
