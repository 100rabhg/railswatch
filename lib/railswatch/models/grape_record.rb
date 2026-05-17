# frozen_string_literal: true

module Railswatch
  module Models
    class GrapeRecord < BaseRecord
      self.table_name = 'railswatch_grape_records'

      def method
        http_method
      end

      def method=(value)
        self.http_method = value
      end

      def endpoint_render_grape
        endpoint_render_grape_ms
      end

      def endpoint_render_grape=(value)
        self.endpoint_render_grape_ms = value
      end

      def endpoint_run_grape
        endpoint_run_grape_ms
      end

      def endpoint_run_grape=(value)
        self.endpoint_run_grape_ms = value
      end

      def format_response_grape
        format_response_grape_ms
      end

      def format_response_grape=(value)
        self.format_response_grape_ms = value
      end

      def payload_hash
        {
          'endpoint_render.grape' => endpoint_render_grape_ms,
          'endpoint_run.grape' => endpoint_run_grape_ms,
          'format_response.grape' => format_response_grape_ms
        }
      end

      def record_hash
        {
          format: self.format,
          status: status,
          method: http_method,
          path: path,
          datetime: occurred_at,
          datetimei: occurred_at.to_i,
          request_id: request_id
        }.merge(payload_hash)
      end
    end
  end
end
