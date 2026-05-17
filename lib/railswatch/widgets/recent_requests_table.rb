# frozen_string_literal: true

module Railswatch
  module Widgets
    class RecentRequestsTable < Table
      def subtitle
        "Recent Requests (last #{Railswatch.recent_requests_time_window / 60} minutes)"
      end

      def data
        @data ||= Railswatch::Reports::RecentRequestsReport.new(datasource.db).data
      end

      def empty_message
        'Nothing to show here. Try to make a few requests in the main app.'
      end

      def auto_update_interval
        '3s'
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
