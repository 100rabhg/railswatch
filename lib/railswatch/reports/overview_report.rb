# frozen_string_literal: true

module Railswatch
  module Reports
    class OverviewReport < BaseReport
      def data
        rows = request_rows
        grouped = grouped_rows(rows)
        build_overview_data(rows, grouped)
      end

      private

      def build_overview_data(rows, grouped)
        {
          total_requests: rows.size,
          average_duration: average_duration(rows),
          error_rate: error_rate(rows),
          slow_requests: slow_request_count(rows),
          unique_endpoints: grouped.keys.size,
          busiest_endpoint: endpoint_volume(grouped),
          slowest_endpoint: slowest_endpoint(grouped),
          latest_request_at: latest_request_at(rows)
        }
      end

      def request_rows
        db.pluck(:controller, :action, :status, :duration_ms, :occurred_at)
      end

      def grouped_rows(rows)
        rows.group_by { |controller, action, *_rest| "#{controller}##{action}" }
      end

      def average_duration(rows)
        return nil if rows.empty?

        rows.sum { |row| duration_value(row) } / rows.size
      end

      def error_rate(rows)
        return 0 if rows.empty?

        (error_count(rows).to_f / rows.size) * 100
      end

      def error_count(rows)
        rows.count { |row| row[2].to_s.start_with?('5') }
      end

      def slow_request_count(rows)
        rows.count { |row| duration_value(row) >= slow_threshold }
      end

      def slow_threshold
        Railswatch.slow_requests_threshold.to_f
      end

      def endpoint_volume(grouped)
        name, samples = grouped.max_by { |_group_name, group_rows| group_rows.size }
        { name: name, count: samples&.size.to_i }
      end

      def slowest_endpoint(grouped)
        name, samples = grouped.max_by do |_group_name, group_rows|
          endpoint_p95(group_rows).to_f
        end

        {
          name: name,
          p95_duration: samples.present? ? endpoint_p95(samples) : nil
        }
      end

      def endpoint_p95(rows)
        Railswatch::Utils.percentile(rows.filter_map { |row| row[3] }, 95)
      end

      def latest_request_at(rows)
        rows.max_by { |row| row[4].to_i }&.last
      end

      def duration_value(row)
        row[3].to_f
      end
    end
  end
end
