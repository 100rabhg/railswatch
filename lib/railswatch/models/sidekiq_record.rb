# frozen_string_literal: true

module Railswatch
  module Models
    class SidekiqRecord < BaseRecord
      self.table_name = 'railswatch_sidekiq_records'

      serialize :job_args, coder: JSON

      def duration
        duration_ms
      end

      def duration=(value)
        self.duration_ms = value
      end

      def payload_hash
        {
          'message' => message,
          'duration' => duration_ms
        }
      end

      def record_hash # rubocop:disable Metrics/MethodLength
        {
          worker: worker,
          queue: queue,
          jid: jid,
          status: status,
          datetimei: occurred_at.to_i,
          datetime: Railswatch::Utils.from_datetimei(start_timei.to_i),
          duration: duration_ms,
          message: message,
          job_args: job_args,
          error_backtrace: error_backtrace
        }
      end
    end
  end
end
