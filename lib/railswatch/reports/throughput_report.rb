# frozen_string_literal: true

module Railswatch
  module Reports
    class ThroughputReport < BaseReport
      def data
        series = db.pluck(:occurred_at).each_with_object(Hash.new(0)) do |occurred_at, buckets|
          bucket = occurred_at.change(sec: 0, usec: 0).to_i * 1000
          buckets[bucket] += 1
        end

        nullify_data(series.transform_values(&:to_f)).map { |x, y| [x, (y || 0).round(2)] }
      end
    end
  end
end
