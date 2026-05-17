# frozen_string_literal: true

module Railswatch
  module Models
    class ResourceRecord < BaseRecord
      self.table_name = 'railswatch_resource_records'

      serialize :payload, coder: JSON

      def json
        payload
      end

      def json=(value)
        self.payload = value
      end

      def payload_hash
        payload || {}
      end

      def record_hash
        payload_hash.symbolize_keys.merge(
          server: server,
          role: role,
          context: context,
          datetime: occurred_at,
          datetimei: occurred_at.to_i
        )
      end
    end
  end
end
