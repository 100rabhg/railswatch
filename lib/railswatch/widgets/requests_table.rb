# frozen_string_literal: true

module Railswatch
  module Widgets
    class RequestsTable < Table
      def subtitle
        'Requests Analysis'
      end

      def data
        @data ||= Railswatch::Reports::RequestsReport.new(
          datasource.db,
          group: :controller_action_format,
          sort: :count
        ).data
      end

      def empty_message
        'No requests recorded yet.'
      end

      def content_partial_path
        'railswatch/railswatch/requests_table_content'
      end
    end
  end
end
