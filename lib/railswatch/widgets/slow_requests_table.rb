# frozen_string_literal: true

module Railswatch
  module Widgets
    class SlowRequestsTable < Table
      def subtitle
        window_minutes = Railswatch.slow_requests_time_window / 60
        threshold = Railswatch.slow_requests_threshold
        "Slow Requests (last #{window_minutes} minutes + slower than #{threshold}ms)"
      end

      def data
        @data ||= Railswatch::Reports::SlowRequestsReport.new(datasource.db).data
      end

      def empty_message
        'Nothing to show here. Try to make a few requests in the main app.'
      end

      def table_id
        'recent'
      end

      def table_classes
        'table is-fullwidth is-hoverable is-narrow'
      end

      def content_partial_path
        'railswatch/railswatch/recent_requests_table_content'
      end
    end
  end
end
