# frozen_string_literal: true

module Railswatch
  module Widgets
    class Table < Base
      def subtitle
        raise NotImplementedError
      end

      def data
        raise NotImplementedError
      end

      def empty_message
        'No data to display.'
      end

      def show_export?
        true
      end

      def auto_update_interval
        nil
      end

      def table_id
        nil
      end

      def table_classes
        'table is-fullwidth is-hoverable'
      end

      def content_partial_path
        raise NotImplementedError, 'Subclasses must define content_partial_path'
      end

      def to_partial_path
        'railswatch/railswatch/table'
      end
    end
  end
end
