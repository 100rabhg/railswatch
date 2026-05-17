# frozen_string_literal: true

module Railswatch
  module Models
    class RakeRecord < BaseRecord
      self.table_name = 'railswatch_rake_records'

      serialize :task, coder: JSON

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
          task: Array.wrap(task),
          datetime: occurred_at,
          datetimei: occurred_at.to_i,
          duration: duration_ms,
          status: status
        }
      end
    end
  end
end
