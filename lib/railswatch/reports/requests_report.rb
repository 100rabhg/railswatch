# frozen_string_literal: true

module Railswatch
  module Reports
    class RequestsReport < BaseReport
      def set_defaults
        @set_defaults ||= :count
      end

      def data
        rows = grouped_rows.map { |group_name, grouped| build_row(group_name, grouped) }
        rows.sort_by { |row| -row[sort].to_f }
      end

      private

      def grouped_rows
        db.pluck(:controller, :action, :format, :duration_ms, :view_runtime_ms, :db_runtime_ms)
          .each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |row, grouped|
            key = group_key(*row.first(3))
            grouped[key] << metrics_hash(row)
          end
      end

      def build_row(group_name, rows) # rubocop:disable Metrics/MethodLength
        durations = metric_values(rows, :duration_ms)
        view_runtimes = metric_values(rows, :view_runtime_ms)
        db_runtimes = metric_values(rows, :db_runtime_ms)

        {
          group: group_name,
          count: rows.size,
          duration_average: average(durations),
          view_runtime_average: average(view_runtimes),
          db_runtime_average: average(db_runtimes),
          duration_slowest: durations.max,
          view_runtime_slowest: view_runtimes.max,
          db_runtime_slowest: db_runtimes.max,
          p50_duration: Railswatch::Utils.percentile(durations, 50),
          p95_duration: Railswatch::Utils.percentile(durations, 95),
          p99_duration: Railswatch::Utils.percentile(durations, 99)
        }
      end

      def group_key(controller, action, format)
        case group
        when :controller_action
          "#{controller}##{action}"
        when :controller
          controller
        else
          "#{controller}##{action}|#{format}"
        end
      end

      def metrics_hash(row)
        {
          duration_ms: row[3],
          view_runtime_ms: row[4],
          db_runtime_ms: row[5]
        }
      end

      def metric_values(rows, key)
        rows.filter_map { |row| row[key] }
      end

      def average(values)
        return nil if values.empty?

        values.sum.to_f / values.size
      end
    end
  end
end
