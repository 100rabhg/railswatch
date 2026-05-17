# frozen_string_literal: true

module Railswatch
  module Reports
    class ResponseTimeReport < BaseReport
      def data
        averages = grouped_durations.transform_values { |values| values.sum.to_f / values.count }
        nullify_data(averages).map { |x, y| [x, y&.round(2) || 0] }
      end

      private

      def grouped_durations
        db.pluck(:occurred_at, :duration_ms).each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |row, buckets|
          occurred_at, duration_ms = row
          next if duration_ms.nil?

          buckets[bucket_key(occurred_at)] << duration_ms
        end
      end

      def bucket_key(occurred_at)
        occurred_at.change(sec: 0, usec: 0).to_i * 1000
      end
    end
  end
end
