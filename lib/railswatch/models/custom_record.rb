# frozen_string_literal: true

module Railswatch
  module Models
    class CustomRecord < BaseRecord
      self.table_name = 'railswatch_custom_records'

      def duration
        duration_ms
      end

      def duration=(value)
        self.duration_ms = value
      end

      def payload_hash
        { 'duration' => duration_ms }
      end

      def record_hash
        {
          tag_name: tag_name,
          namespace_name: namespace_name,
          status: status,
          datetimei: occurred_at.to_i,
          datetime: occurred_at,
          duration: duration_ms
        }
      end
    end
  end
end
