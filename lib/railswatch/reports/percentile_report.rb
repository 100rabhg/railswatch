# frozen_string_literal: true

module Railswatch
  module Reports
    class PercentileReport < BaseReport
      def data
        durations = db.pluck(:duration_ms).compact
        {
          p50: Railswatch::Utils.percentile(durations, 50),
          p95: Railswatch::Utils.percentile(durations, 95),
          p99: Railswatch::Utils.percentile(durations, 99)
        }
      end
    end
  end
end
