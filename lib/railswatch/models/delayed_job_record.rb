# frozen_string_literal: true

module Railswatch
  module Models
    class DelayedJobRecord < BaseRecord
      self.table_name = 'railswatch_delayed_job_records'

      serialize :job_args, coder: JSON

      def duration
        duration_ms
      end

      def duration=(value)
        self.duration_ms = value
      end

      def payload_hash
        { 'duration' => duration_ms }
      end

      def record_hash # rubocop:disable Metrics/MethodLength
        {
          jid: jid,
          datetime: occurred_at,
          datetimei: occurred_at.to_i,
          duration: duration_ms,
          status: status,
          source_type: source_type,
          class_name: class_name,
          method_name: method_name,
          job_args: job_args,
          error_message: error_message,
          error_backtrace: error_backtrace
        }
      end
    end
  end
end
