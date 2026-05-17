# frozen_string_literal: true

module Railswatch
  module Models
    class RequestRecord < BaseRecord
      self.table_name = 'railswatch_request_records'

      serialize :custom_data, coder: JSON
      serialize :backtrace, coder: JSON
      serialize :request_context, coder: JSON

      attr_accessor :exception_object

      validates :request_id, presence: true
      validates :occurred_at, presence: true

      def method
        http_method
      end

      def method=(value)
        self.http_method = value
      end

      def view_runtime
        view_runtime_ms
      end

      def view_runtime=(value)
        self.view_runtime_ms = value
      end

      def db_runtime
        db_runtime_ms
      end

      def db_runtime=(value)
        self.db_runtime_ms = value
      end

      def duration
        duration_ms
      end

      def duration=(value)
        self.duration_ms = value
      end

      def controller_action
        "#{controller}##{action}"
      end

      def controller_action_format
        "#{controller}##{action}|#{format}"
      end

      def payload_hash
        {
          'view_runtime' => view_runtime_ms,
          'db_runtime' => db_runtime_ms,
          'duration' => duration_ms,
          'http_referer' => http_referer,
          'custom_data' => custom_data,
          'exception' => exception,
          'backtrace' => backtrace,
          'request_context' => request_context
        }
      end

      def record_hash
        base_record_hash.merge(custom_record_hash)
      end

      def base_record_hash # rubocop:disable Metrics/MethodLength
        {
          controller: controller,
          action: action,
          format: self.format,
          status: status,
          method: http_method,
          path: path,
          request_id: request_id,
          datetime: occurred_at,
          datetimei: occurred_at.to_i,
          duration: duration_ms,
          db_runtime: db_runtime_ms,
          view_runtime: view_runtime_ms,
          exception: exception,
          backtrace: backtrace,
          http_referer: http_referer,
          request_context: request_context
        }
      end

      def custom_record_hash
        custom_data.is_a?(Hash) ? custom_data.deep_symbolize_keys : {}
      end

      before_save do
        self.exception = Array.wrap(exception).compact.join(' ') if exception.is_a?(Array)
        self.backtrace = exception_object.backtrace.take(20) if exception_object
      end
    end
  end
end
