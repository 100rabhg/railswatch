# frozen_string_literal: true

module Railswatch
  module Widgets
    class CrashesTable < Table
      def subtitle
        'Crash Report'
      end

      def data
        @data ||= Railswatch::Reports::CrashReport.new(datasource.db).data
      end

      def empty_message
        'We are glad that this list is empty ;)'
      end

      def table_classes
        'table is-fullwidth is-hoverable is-narrow'
      end

      def content_partial_path
        'railswatch/railswatch/crashes_table_content'
      end
    end
  end
end
