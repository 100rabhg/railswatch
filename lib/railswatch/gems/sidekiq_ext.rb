# frozen_string_literal: true

module Railswatch
  module Gems
    class SidekiqExt
      def initialize(options = nil); end

      def call(worker, msg, queue) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        now = Railswatch::Utils.time
        payload = msg.is_a?(Hash) ? msg : {}
        queue_name = queue.respond_to?(:call) ? nil : queue
        record = build_record(worker, payload, queue_name, now)

        result = yield
        record.status = 'success'
        result
      rescue Exception => e # rubocop:disable Lint/RescueException
        record.status = 'exception'
        record.message = e.message
        record.error_backtrace = e.backtrace&.take(20)&.join("\n")
        raise e
      ensure
        persist_record(record, now)
      end

      private

      def persist_record(record, started_at)
        return unless record

        record.duration = (Railswatch::Utils.time - started_at) * 1000
        record.save
        CurrentRequest.cleanup
      end

      def build_record(worker, payload, queue_name, now) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        filtered = Railswatch::Utils.filter_params({ 'args' => Array.wrap(payload['args']) })
        Railswatch::Models::SidekiqRecord.new(
          enqueued_ati: present_to_i(payload['enqueued_at']),
          datetimei: present_to_i(payload['created_at']),
          jid: payload['jid'].presence || SecureRandom.hex(12),
          queue: queue_name.presence || 'default',
          start_timei: now.to_i,
          datetime: now.strftime(Railswatch::FORMAT),
          worker: payload['wrapped'].presence || worker.to_s,
          job_args: filtered['args']
        )
      end

      def present_to_i(val)
        val.present? ? val.to_i : nil
      end
    end
  end
end
